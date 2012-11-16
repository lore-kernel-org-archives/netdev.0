From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH] net: phy: smsc: Re-enable EDPD mode for LAN87xx
Date: Fri, 16 Nov 2012 01:04:33 +0100
Message-ID: <201211160104.33846.marex@denx.de>
References: <1353006057-7593-1-git-send-email-patrick.trantham@fuel7.com> <20121115.174910.1186195664618812261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patrick.trantham@fuel7.com, netdev@vger.kernel.org,
	steve.glendinning@shawell.net, otavio@ossystems.com.br,
	chohnstaedt@innominate.com, jkosina@suse.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:40446 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab2KPAEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 19:04:39 -0500
In-Reply-To: <20121115.174910.1186195664618812261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

> From: Patrick Trantham <patrick.trantham@fuel7.com>
> Date: Thu, 15 Nov 2012 13:00:57 -0600
> 
> > This patch re-enables Energy Detect Power Down (EDPD) mode for the
> > LAN8710/LAN8720.  EDPD mode was disabled in a previous commit,
> > (b629820d18fa65cc598390e4b9712fd5f83ee693), because it was causing the
> > PHY to not be able to detect a link when cold started without a cable
> > connected.
> > 
> > The LAN8710/LAN8720 requires a minimum of 2 link pulses within 64ms of
> > each other in order to set the ENERGYON bit and exit EDPD mode.  If a
> > link partner does send the pulses within this interval, the PHY will
> > remained powered down.
> > 
> > This workaround will manually toggle the PHY on/off upon calls to
> > read_status in order to generate link test pulses if the link is down.
> > If a link partner is present, it will respond to the pulses, which will
> > cause the ENERGYON bit to be set and will cause the EDPD mode to be
> > exited.
> > 
> > Signed-off-by: Patrick Trantham <patrick.trantham@fuel7.com>
> 
> Applied to net-next, thanks.

Can you please wait a bit until it gets a few tests ?

Best regards,
Marek Vasut
