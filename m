From: Marek Vasut <marex@denx.de>
Subject: Re: Freescale FEC packet loss
Date: Sun, 26 Jan 2014 20:12:12 +0100
Message-ID: <201401262012.13051.marex@denx.de>
References: <201401222255.29467.marex@denx.de> <1390762590.2735.39.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>, fugang.duan@freescale.com,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	Hector Palacios <hector.palacios@digi.com>,
	linux-arm-kernel@lists.infradead.org, Detlev Zundel <dzu@denx.de>,
	Eric Nelson <eric.nelson@boundarydevices.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:47161 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbaAZTMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 14:12:25 -0500
In-Reply-To: <1390762590.2735.39.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, January 26, 2014 at 07:56:30 PM, Ben Hutchings wrote:
> On Wed, 2014-01-22 at 22:55 +0100, Marek Vasut wrote:
> > Hi guys,
> > 
> > I am running stock Linux 3.13 on i.MX6Q SabreLite board. The CPU is
> > i.MX6Q TO 1.0 .
> > 
> > I am hitting a WARNING when I use the FEC ethernet to transfer data, thus
> > I started investigating this problem. TL;DR I am not able to figure this
> > problem out, so I am not attaching a patch :-(
> > 
> > Steps to reproduce:
> > -------------------
> > 1) Boot stock Linux 3.13 on i.MX6Q SabreLite board
> > 2) Plug in an SD card into one of the SD slots (I use the full-size one)
> > 3) Plug in an USB stick into one of the USB ports (I use the upper one)
> > 4) Plug in an ethernet cable into the board
> > 
> >    -> Connect the other side into a gigabit-capable PC
> 
> [...]
> 
> I think there are known problems with 1000BASE-T on the Sabre Lite
> board.

This is MX6-wide thing, not sabrelite specific actually.

> Two possible workarounds are to limit the PHY to 100BASE-TX
> (should be doable with ethtool) or force it to be clock master for
> 1000BASE-T (requires a driver patch).

Can you please elaborate on the later ? I don't quite understand that.

> The vendor kernel apparently does both!

More like the vendor kernel papers over this bug.

> Matthew Garrett has been trying to implement a workaround in a
> clean way.

Do you have any pointers about this please ?

Best regards,
Marek Vasut
