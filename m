From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Fri, 23 May 2008 11:04:12 +0800
Message-ID: <989B956029373F45A0B8AF02970818900250D550@zch01exm26.fsl.freescale.net>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se> <4835B60F.6070904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Joakim Tjernlund" <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:45039 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760485AbYEWDET convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 23:04:19 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m4N34F6x008176
	for <netdev@vger.kernel.org>; Thu, 22 May 2008 20:04:16 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m4N34EBJ001486
	for <netdev@vger.kernel.org>; Thu, 22 May 2008 22:04:14 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <4835B60F.6070904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org] 
> Sent: Friday, May 23, 2008 2:06 AM
> To: Joakim Tjernlund
> Cc: Netdev; Li Yang
> Subject: Re: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
> 
> Joakim Tjernlund wrote:
> > Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> > Fix it and a few others while I am there. Strangely, the 
> > rx-jumbo-frames counter still counts pkgs even though I think there 
> > isn't any packtes above 1518.
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> > 
> > Havn't seen this go in or ACK/NACK. Resending.
> > 
> >  drivers/net/ucc_geth_ethtool.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> still looking for maintainer's ack...

This patch still need some change.

Joakim,

Could you respin this patch without deleting the two counters?

- Leo
