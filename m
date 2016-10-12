From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC] net: phy: smsc: Disable auto-negotiation on startup
Date: Wed, 12 Oct 2016 02:13:06 -0700
Message-ID: <0c2488d0-45f5-1ab7-bfa5-f19ae687a90f@gmail.com>
References: <20161010174123.21436-1-kyle.roeschley@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Kyle Roeschley <kyle.roeschley@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34993 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932105AbcJLJPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 05:15:46 -0400
In-Reply-To: <20161010174123.21436-1-kyle.roeschley@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2016 10:41 AM, Kyle Roeschley wrote:
> Because the SMSC PHY completes auto-negotiation before the driver is
> ready to handle interrupts, the PHY state machine never realizes that we
> have a link. Clear the ANENABLE bit on initialization, which lets
> genphy_config_aneg do its thing when that code is hit later.
> 
> While this patch does fix the problem we see (no link on boot without
> re-plugging the cable), it seems like the generic PHY code should be
> able to handle auto-negotiation completing before interrupts are
> enabled. Submitted as an RFC in the hopes that someone has an idea as to
> how that could be done.
> 
> This fix is copied from commit 99f81afc139c ("phy: micrel: Disable auto
> negotiation on startup").

Do you mind trying:

https://www.spinics.net/lists/netdev/msg397857.html

and see if you do get link interrupts without your patch applied? Thanks!
-- 
Florian
