From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: invalid requirement from ethtool?
Date: Thu, 28 Jul 2011 10:23:26 +0300
Message-ID: <20110728072326.GC6750@mtldesk30>
References: <20110726124222.GA4842@mtldesk30>
 <20110727.224309.779719590419361909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59697 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab1G1HXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:23:32 -0400
Received: by wyg8 with SMTP id 8so1492086wyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 00:23:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110727.224309.779719590419361909.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2011 at 10:43:09PM -0700, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Tue, 26 Jul 2011 15:42:22 +0300
> 
> > I think both params zero should be allowed and mean coalescing is not
> > operational, thus we can remove these comments from ethtool.h
> 
> The existing precendence has existed for more than 10 years.  You can't
> just change it like this.
> 
> You'll need to find a new way to encode "disabled" coalescing.

I can't see the text explicitly specifies how to "disable" coalescing.
If I ignore the specific comment that disallows both params 0, I could
interpret the text such that when they're both zero, the feature is
disabled.

BTW, I checked also Intel 10GBE Nic (ixgbe) driver and it allows
setting both 0.
