From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram implementation
Date: Thu, 17 Apr 2008 11:38:19 +0800
Message-ID: <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net>
References: <20080320173945.GA8446@localhost.localdomain><20080414181810.GA1038@polina.dev.rtsoft.ru> <20080416182214.GA20056@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1251"
Content-Transfer-Encoding: 8BIT
Cc: "Wood Scott" <scottwood@freescale.com>, <linuxppc-dev@ozlabs.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"Tabi Timur" <timur@freescale.com>, <netdev@vger.kernel.org>
To: <avorontsov@ru.mvista.com>,
	"Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:38636 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568AbYDQDij convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 23:38:39 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m3H3cWbh002918
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 20:38:32 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id m3H3cTC3022169
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 22:38:30 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20080416182214.GA20056@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org 
> [mailto:linuxppc-dev-bounces+leoli=freescale.com@ozlabs.org] 
> On Behalf Of Anton Vorontsov
> Sent: Thursday, April 17, 2008 2:22 AM
> To: Kumar Gala
> Cc: Wood Scott; linuxppc-dev@ozlabs.org; Jeff Garzik; Tabi 
> Timur; netdev@vger.kernel.org
> Subject: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to 
> the cpm_muramimplementation
> 
> This is very trivial patch. We're transitioning to the 
> cpm_muram_* calls. That's it.

Hi Anoton,

It is a good thing to unify the CPM dpram operation and QE muram operation.  But I'm having concerns about the naming as CPM is an obsolete block.  Can we change to use the new name QE instead?

- Leo
