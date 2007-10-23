From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Tue, 23 Oct 2007 12:10:05 -0500
Message-ID: <20071023171005.GA4638@loki.buserror.net>
References: <20071019.164143.75786621.davem@davemloft.net> <598D5675D34BE349929AF5EDE9B03E2701685446@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Medve Emilian-EMMEDVE1 <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:53760 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbXJWRKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 13:10:48 -0400
Content-Disposition: inline
In-Reply-To: <598D5675D34BE349929AF5EDE9B03E2701685446@az33exm24.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 06:47:32AM -0700, Medve Emilian-EMMEDVE1 wrote:
> Are you suggesting we leave those warnings there until somebody decides
> to fix all the portability issues of this driver? My patch is a small
> and insignificant improvement and not the revolution you're asking for,
> but is an small improvement today (I dislike warnings) vs. an improbable
> big one in the future.

It is not an improvement, as it moves the driver further away from being
64-bit clean.  A better fix would be to change the definition of
tx/rx_bd_ring_offset to unsigned long (or better yet, a union).

-Scott
