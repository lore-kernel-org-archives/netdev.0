From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/9] net: dsa: misc improvements
Date: Fri, 3 Jun 2016 17:10:06 -0700
Message-ID: <57521C5E.2010706@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32873 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbcFDAKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:10:08 -0400
Received: by mail-pf0-f174.google.com with SMTP id b124so48306407pfb.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:10:08 -0700 (PDT)
In-Reply-To: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 05:05 PM, Florian Fainelli wrote:
> Hi all,
> 
> This patch series builds on top of Andrew's "New DSA bind, switches as devices"
> patch set and does the following:
> 
> - add support for the old DSA binding with the new dsa_register_switch() API
>   which is needed by some platforms where the Device Tree is pretty much frozen
> 
> - add a few helper functions/goodies for net/dsa/dsa2.c to be as close as possible
>   from net/dsa/dsa.c in terms of what drivers can expect, in particular the slave
>   MDIO bus and the enabled_port_mask and phy_mii_mask
> 
> - fix the CPU port ethtools ops to work in a multiple tree setup since we can
>   no longer assume a single tree is supported
> 
> - finally conver the bcm_sf2 driver to be a true platform device driver and
>   slightly rework its internal vs. external MDIO bus indirect read/writes to
>   be cleaner

David, I cleaned up my mess in patchwork to leave just the relevant
patches for you to review and apply, sorry about that, it's Friday.
-- 
Florian
