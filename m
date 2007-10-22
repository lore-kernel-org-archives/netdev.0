From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Mon, 22 Oct 2007 06:47:32 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E2701685446@az33exm24.fsl.freescale.net>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com><20071018.173032.48505868.davem@davemloft.net><598D5675D34BE349929AF5EDE9B03E270168520B@az33exm24.fsl.freescale.net> <20071019.164143.75786621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, "Li Yang-r58472" <LeoLi@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:52150 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500AbXJVNrl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 09:47:41 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l9MDlXlY012748
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 06:47:34 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id l9MDlXWT029839
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 08:47:33 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20071019.164143.75786621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,


> No piece of code in the kernel should live in a vacuum.
> 
> In order to improve overall code quality, every piece of
> driver code should avoid assuming things about pointer
> sizes and things of this nature.

I'm afraid we might be talking about orthogonal issues here. I actively
agree that all code (not only kernel) should be written up to the
coding/quality standards you mention above, but I see a difference
between fixing a warning and making a driver portable (to 64-bit
PowerPCs, to other platforms, etc.). If there is a kernel todo list
somewhere lets add to it the task to make the ucc_geth more portable.

> Then the driver can get enabled into the build on every
> platform, and therefore nobody will break the build of
> this driver again since it will get hit by "allmodconfig"
> et al. builds even on platforms other than the one it is
> meant for.
> 
> This hack fix is not acceptable, really.

Are you suggesting we leave those warnings there until somebody decides
to fix all the portability issues of this driver? My patch is a small
and insignificant improvement and not the revolution you're asking for,
but is an small improvement today (I dislike warnings) vs. an improbable
big one in the future.

Leo, as author and maintainer of this driver, what's your take on this?


Cheers,
Emil.
