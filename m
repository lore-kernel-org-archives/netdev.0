From: "Haruki Dai" <Dai.Haruki@freescale.com>
Subject: RE: [PATCH] gianfar: Revive VLAN support
Date: Mon, 26 Jan 2009 16:39:55 -0700
Message-ID: <18AEF66AFDF06F4CAAA1D419D000FD33029D5F46@az33exm24.fsl.freescale.net>
References: <20090126205043.GA15581@oksana.dev.rtsoft.ru> <324701F1-4A84-41A6-BC2D-4A61A8E135D9@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: "Fleming Andy-AFLEMING" <afleming@freescale.com>,
	"Anton Vorontsov" <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:65505 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbZAZXkG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 18:40:06 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n0QNdvNp017299
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 16:39:57 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n0QNduDI023037
	for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 17:39:56 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <324701F1-4A84-41A6-BC2D-4A61A8E135D9@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Fleming Andy-AFLEMING
> Sent: Monday, January 26, 2009 3:08 PM
> To: Anton Vorontsov
> Cc: Jeff Garzik; David Miller; Haruki Dai-R35557;
netdev@vger.kernel.org;
> linuxppc-dev@ozlabs.org
> Subject: Re: [PATCH] gianfar: Revive VLAN support
> 
> 
> On Jan 26, 2009, at 2:50 PM, Anton Vorontsov wrote:
> 
> > commit 77ecaf2d5a8bfd548eed3f05c1c2e6573d5de4ba ("gianfar: Fix VLAN
> > HW feature related frame/buffer size calculation") wrongly removed
> > priv->vlgrp assignment, and now priv->vlgrp is always NULL.
> >
> > This patch fixes the issue, plus fixes following sparse warning
> > introduced by the same commit:
> > gianfar.c:1406:13: warning: context imbalance in
> > 'gfar_vlan_rx_register' - wrong count at exit
> >
> > gfar_vlan_rx_register() checks for "if (old_grp == grp)" and tries
> > to return w/o dropping the lock.
> >
> > According to net/8021q/vlan.c VLAN core issues rx_register()
callback:
> > 1. In register_vlan_dev() only on a newly created group;
> > 2. In unregister_vlan_dev() only if the group becomes empty.
> >
> > Thus the check in the gianfar driver isn't needed.
> >
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Acked-by: Dai Haruki <dai.haruki@freescale.com>

