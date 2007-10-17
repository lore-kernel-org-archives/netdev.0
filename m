From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] [net] fix gianfar (compile and warning)
Date: Wed, 17 Oct 2007 10:38:29 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B5A3A@zch01exm26.fsl.freescale.net>
References: <E1IhqCT-0007Wu-Lz@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Grant Likely" <grant.likely@secretlab.ca>
To: "Sebastian Siewior" <netdev@ml.breakpoint.cc>, <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:62036 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036AbXJQCif convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 22:38:35 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l9H2cWhW015273
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 19:38:32 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id l9H2cUa7005916
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 21:38:31 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <E1IhqCT-0007Wu-Lz@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Sebastian Siewior [mailto:netdev@ml.breakpoint.cc] 
> Sent: Wednesday, October 17, 2007 1:25 AM
> To: jeff@garzik.org
> Cc: Li Yang-r58472; netdev@vger.kernel.org; Grant Likely
> Subject: [PATCH] [net] fix gianfar (compile and warning)
> 
> Currently it does not compile because a not declared variable is used.
> struct net_device_stats in driver's private struct is also unsued.
> This patch uses (hopefully) the right stats.
> 
> Cc: Li Yang <leoli@freescale.com>
> Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>

I have also submitted a patch to fixed this compile error two days
before, and it has been applied on Jeff's netdev tree.  But you can
submit a separate patch to cleanup the struct net_device_stats in
driver's private struct. Thanks.

- Leo
