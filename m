From: "Li Yang" <LeoLi@freescale.com>
Subject: RE: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram implementation
Date: Fri, 18 Apr 2008 11:29:12 +0800
Message-ID: <989B956029373F45A0B8AF029708189002007624@zch01exm26.fsl.freescale.net>
References: <20080416182214.GA20056@polina.dev.rtsoft.ru> <989B956029373F45A0B8AF02970818900200750D@zch01exm26.fsl.freescale.net> <20080417141043.GA21793@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <avorontsov@ru.mvista.com>,
	"Kumar Gala" <galak@kernel.crashing.org>,
	<linuxppc-dev@ozlabs.org>, "Jeff Garzik" <jgarzik@pobox.com>,
	"Tabi Timur" <timur@freescale.com>, <netdev@vger.kernel.org>
To: "Wood Scott" <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36326 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbYDRD3Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 23:29:24 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m3I3TGjC015353
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 20:29:16 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m3I3TErO017061
	for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 22:29:15 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20080417141043.GA21793@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wood Scott 
> Sent: Thursday, April 17, 2008 10:11 PM
> To: Li Yang
> Cc: avorontsov@ru.mvista.com; Kumar Gala; 
> linuxppc-dev@ozlabs.org; Jeff Garzik; Tabi Timur; 
> netdev@vger.kernel.org
> Subject: Re: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch 
> to the cpm_muram implementation
> 
> On Wed, Apr 16, 2008 at 08:38:19PM -0700, Li Yang wrote:
> > It is a good thing to unify the CPM dpram operation and QE muram 
> > operation.  But I'm having concerns about the naming as CPM is an 
> > obsolete block.  Can we change to use the new name QE instead?
> 
> And then change it again when marketing decides that CPM4 
> will be called something other than QE2? :-P

It's a good point. :)  Technically they are quite similar.  But they are
not so well known as Pentium to x86.  The change will cause confusion
especially when both of the terms of CPM and QE are used in one file.  I
agree with Kumar's suggestion that we keep both names.

- Leo
