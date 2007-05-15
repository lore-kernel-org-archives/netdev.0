From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH 3/5] ucc_geth: eliminate max-speed, change
 interface-type to phy-connection-type
Date: Tue, 15 May 2007 17:26:29 -0500
Message-ID: <20070515172629.61c1b4c2.kim.phillips@freescale.com>
References: <20070511182507.7642926e.kim.phillips@freescale.com>
	<464A29EF.7080405@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:56542 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756566AbXEOW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:26:40 -0400
In-Reply-To: <464A29EF.7080405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007 17:45:19 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Kim Phillips wrote:
> > It was agreed that phy-connection-type was a better name for
> > the interface-type property, so this patch renames it.
> > 
> > Also, the max-speed property name was determined too generic,
> > and is therefore eliminated in favour of phy-connection-type
> > derivation logic.
> > 
> > includes corrections to copyright text.
> > 
> > Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> > ---
> >  drivers/net/ucc_geth.c     |   40 ++++++++++++++++------------------------
> >  drivers/net/ucc_geth_mii.c |    9 +++++----
> >  drivers/net/ucc_geth_mii.h |   10 +++++-----
> >  3 files changed, 26 insertions(+), 33 deletions(-)
> 
> applied to #upstream
> 
just to be clear; only the mpc8323e-mds board works on your current #upstream-{fixes,linus}.

The mpc8323e-rdb and mpc8360e-mds require

phylib: add the ICPlus IP175C PHY driver

and 

phylib: enable RGMII-ID on the Marvell m88e1111 PHY

respectively in order to work.

I'm ok with the SGMII patches:

phylib: m88e1111: enable SGMII mode
gianfar: add support for SGMII

staying on #upstream, but 2 out of 3 boards are currently broken for #upstream-{fixes,linus}.

Kim
