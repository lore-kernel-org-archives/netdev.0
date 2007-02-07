From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Wed, 7 Feb 2007 17:34:18 +0800
Message-ID: <989B956029373F45A0B8AF02970818900D4332@zch01exm26.fsl.freescale.net>
References: <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:60566 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030600AbXBGJdH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 04:33:07 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l179X45x019448
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 02:33:04 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l179X1KI025308
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 03:33:03 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <001EB06E-FC1D-4F0A-A910-8E08EE0B8CE2@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Feb 6, 2007, at 5:31 AM, Li Yang wrote:
> 
> > Get rid of private immrbar_virt_to_phys() routine and
> > use generic iopa().
> 
> Nack. iopa() isn't that generic, shouldn't we really be using the dma
> mapping API here?

Do you mean the dma_map_single()?  dma_map_single can map memory space
correctly, but I don't think it can handle ioremap-ed space.

- Leo
