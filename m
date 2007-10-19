From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Fri, 19 Oct 2007 16:41:43 -0700 (PDT)
Message-ID: <20071019.164143.75786621.davem@davemloft.net>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
	<20071018.173032.48505868.davem@davemloft.net>
	<598D5675D34BE349929AF5EDE9B03E270168520B@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, LeoLi@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Emilian.Medve@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757554AbXJSXla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 19:41:30 -0400
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E270168520B@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Date: Fri, 19 Oct 2007 06:39:12 -0700

> For the current situation, 32-bit QE, 32-bit PowerPC, do you find
> the patch acceptable?

No piece of code in the kernel should live in a vacuum.

In order to improve overall code quality, every piece of
driver code should avoid assuming things about pointer
sizes and things of this nature.

Then the driver can get enabled into the build on every
platform, and therefore nobody will break the build of
this driver again since it will get hit by "allmodconfig"
et al. builds even on platforms other than the one it is
meant for.

This hack fix is not acceptable, really.
