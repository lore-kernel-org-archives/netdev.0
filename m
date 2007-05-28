From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 2/5] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
Date: Mon, 28 May 2007 16:13:38 +0800
Message-ID: <989B956029373F45A0B8AF0297081890D29F7D@zch01exm26.fsl.freescale.net>
References: <20070511182502.31a8aad0.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Phillips Kim-R1AAHA" <Kim.Phillips@freescale.com>,
	"Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:58964 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbXE1ILy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 04:11:54 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l4S8BpFR004830
	for <netdev@vger.kernel.org>; Mon, 28 May 2007 01:11:51 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l4S8BnR1014891
	for <netdev@vger.kernel.org>; Mon, 28 May 2007 03:11:50 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20070511182502.31a8aad0.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Kim Phillips
> Sent: Saturday, May 12, 2007 7:25 AM
> To: Jeff Garzik; netdev@vger.kernel.org
> Subject: [PATCH 2/5] phylib: enable RGMII-ID on the Marvell m88e1111
PHY
> 
> Support for configuring RGMII-ID (RGMII with internal delay) mode on
the
> 88e1111 and 88e1145.
> 
> Also renamed 88e1111s -> 88e1111 (no references to an 88e1111s part
were
> found), and fixed some whitespace.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>

Hi Jeff,

Please help to push this patch upstream before 2.6.22.  The merged
patches for changing ucc_geth to use phylib caused regression on
MPC8360EMDS board.  This patch fixes it.

Thanks,
Leo
