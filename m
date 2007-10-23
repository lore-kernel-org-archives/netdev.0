From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Tue, 23 Oct 2007 11:38:25 +0800
Message-ID: <989B956029373F45A0B8AF0297081890019B5E2E@zch01exm26.fsl.freescale.net>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com><20071018.173032.48505868.davem@davemloft.net><598D5675D34BE349929AF5EDE9B03E270168520B@az33exm24.fsl.freescale.net> <20071019.164143.75786621.davem@davemloft.net> <598D5675D34BE349929AF5EDE9B03E2701685446@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:44286 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbXJWDig convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 23:38:36 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l9N3cTJb004213
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 20:38:29 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l9N3cRls028565
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 22:38:28 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E2701685446@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Medve Emilian-EMMEDVE1 
> Sent: Monday, October 22, 2007 9:48 PM
> To: David Miller
> Cc: jgarzik@pobox.com; Li Yang-r58472; 
> netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
> Subject: RE: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
> 
> Hello David,
> 
> 
> > No piece of code in the kernel should live in a vacuum.
> > 
> > In order to improve overall code quality, every piece of 
> driver code 
> > should avoid assuming things about pointer sizes and things of this 
> > nature.
> 
> I'm afraid we might be talking about orthogonal issues here. 
> I actively agree that all code (not only kernel) should be 
> written up to the coding/quality standards you mention above, 
> but I see a difference between fixing a warning and making a 
> driver portable (to 64-bit PowerPCs, to other platforms, 
> etc.). If there is a kernel todo list somewhere lets add to 
> it the task to make the ucc_geth more portable.
> 
> > Then the driver can get enabled into the build on every 
> platform, and 
> > therefore nobody will break the build of this driver again since it 
> > will get hit by "allmodconfig"
> > et al. builds even on platforms other than the one it is meant for.
> > 
> > This hack fix is not acceptable, really.
> 
> Are you suggesting we leave those warnings there until 
> somebody decides to fix all the portability issues of this 
> driver? My patch is a small and insignificant improvement and 
> not the revolution you're asking for, but is an small 
> improvement today (I dislike warnings) vs. an improbable big 
> one in the future.

I'd say we can not use our way of doing things while working with the
community.  The community has to consider the kernel as a whole and thus
has its own virtue.  The warning has been there for some time.  It stays
as an indicator that we have something to do to improve the portability.
I will work on a patch to fix this portability issue.

- Leo

