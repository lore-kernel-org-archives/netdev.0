From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 0/2] Adding new TI Common Platform ethernet SWitch
 driver
Date: Mon, 19 Mar 2012 21:06:36 -0700
Message-ID: <1332216396.22737.29.camel@edumazet-glaptop>
References: <1332137874-3247-1-git-send-email-mugunthanvnm@ti.com>
	 <20120319.180659.2108026289616852615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:52829 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab2CTEGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 00:06:40 -0400
Received: by dajr28 with SMTP id r28so10841261daj.19
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2012 21:06:39 -0700 (PDT)
In-Reply-To: <20120319.180659.2108026289616852615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-19 at 18:06 -0400, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Mon, 19 Mar 2012 11:47:52 +0530
> 
> > The following series contains driver implementation for TI Common Platform
> > ethernet SWitch (CPSW) driver.
> > 
> > CPSW is found in following SoC.
> > * AM335X - http://www.ti.com/litv/pdf/spruh73c
> > * DM814X - http://www.ti.com/litv/pdf/sprugz8
> > 
> > CPSW:
> > The three port switch gigabit ethernet subsystem provides ethernet packet
> > communication and can be configured as an ethernet switch.  It
> > supports 10/100/1000 Mbps. It provides the gigabit media independent
> > interface (G/MII), reduced gigabit media independent interface (RGMII),
> > reduced media independent interface (RMII), the management data input
> > output (MDIO) for physical layer device (PHY) management.
> 
> All applied.

It appears this driver doesnt have a ndo_change_mtu method, so I suspect
some bad things could happen.

I wonder if we should WARN is netdev_ops->ndo_change_mtu is NULL

For an ethernet driver, using eth_change_mtu seems the right thing.
