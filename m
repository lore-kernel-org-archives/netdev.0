From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Tue, 20 Nov 2007 19:08:51 +0800
Message-ID: <989B956029373F45A0B8AF029708189001A1C75B@zch01exm26.fsl.freescale.net>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <paulus@samba.org>
To: <jgarzik@pobox.com>, "Phillips Kim" <Kim.Phillips@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:42267 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbXKTLJD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 06:09:03 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id lAKB8tJr019702
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 04:08:55 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id lAKB8r0e015613
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 05:08:54 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Phillips Kim 
> Sent: Tuesday, November 06, 2007 2:16 AM
> To: Li Yang-r58472; Kumar Gala; netdev@vger.kernel.org; 
> linuxppc-dev@ozlabs.org
> Cc: jgarzik@pobox.com; paulus@samba.org
> Subject: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 
> (RGMII Timing)
> 
> Hello all,
> 
> the following patches fix RGMII timing for rev. 2.1 of the 
> mpc8360, according to erratum #2 (erratum text included 
> below).  Basically the most intrusive part is the addition of 
> two new RGMII Internal Delay modes; one for TX delay only, 
> and the other for RX delay only (i.e, not both at the same time).
> 
> Please review, and since this affects both netdev and powerpc 
> trees, one maintainer should ack them for the other to push 
> upstream (i.e, Kumar acks them, and Leo picks them up to go 
> through netdev or the other way around; either way is fine 
> with me).  I'm hoping they're trivial enough to go in 2.6.24.
> 
> Depending on how the review goes, a follow-on patch to u-boot 
> will be sent out that fixes up the phy-connection-type in the 
> device tree (from "rgmii-id" to "rgmii-rxid" iff on mpc8360rev2.1).
> 

2-4
Acked-by: Li Yang <leoli@freescale.com>
