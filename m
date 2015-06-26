From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/3] net: phy: bcm7xxx initial read/write workaround
Date: Fri, 26 Jun 2015 10:39:52 -0700
Message-ID: <558D8E68.2090005@gmail.com>
References: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34421 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbbFZRl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:41:27 -0400
Received: by pabvl15 with SMTP id vl15so72204353pab.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:41:27 -0700 (PDT)
In-Reply-To: <1435340314-10229-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/06/15 10:38, Florian Fainelli wrote:
> Hi David,
> 
> This patch series fixes occasional BCM7xxx PHY driver binding failure due
> to a harware bug where the first read or write does not come out of the PHY
> MDIO management controller.
> 
> Since we have two different MDIO controllers using this PHY, a similar
> need to be replicated in GENET and UniMAC MDIO.

Mistankely sent a previous patch as part of this series, the latest
submission is correct.
-- 
Florian
