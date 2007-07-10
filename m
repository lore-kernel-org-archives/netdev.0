From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] QE Ethernet driver writes to wrong register to mask interrupts
Date: Tue, 10 Jul 2007 20:59:31 +0800
Message-ID: <989B956029373F45A0B8AF0297081890F05D0B@zch01exm26.fsl.freescale.net>
References: <11840718711477-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Tabi Timur-B04825" <timur@freescale.com>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:49557 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842AbXGJM5j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:57:39 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id l6ACvaPo010756
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 05:57:36 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l6ACvYjB007913
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2007 07:57:35 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <11840718711477-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Tabi Timur-B04825
> Sent: Tuesday, July 10, 2007 8:51 PM
> To: jgarzik@pobox.com; netdev@vger.kernel.org
> Cc: Tabi Timur-B04825
> Subject: [PATCH] QE Ethernet driver writes to wrong register to mask
interrupts
> 
> The QE Ethernet driver was writing to the wrong register to mask
interrupts.
> In ucc_geth_stop(), it was clearing UCCE instead of UCCM.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
Acked-by: Li Yang <leoli@freescale.com>
