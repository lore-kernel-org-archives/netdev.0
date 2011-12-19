From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 16:33:38 +0100
Message-ID: <20111219153338.GV24496@pengutronix.de>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219151958.GU24496@pengutronix.de>
 <20111219152418.GF2031@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mircea Gherzan <mgherzan@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dave Martin <dave.martin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34789 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab1LSPdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:33:41 -0500
Content-Disposition: inline
In-Reply-To: <20111219152418.GF2031@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Dec 19, 2011 at 03:24:18PM +0000, Dave Martin wrote:
> On Mon, Dec 19, 2011 at 04:19:58PM +0100, Uwe Kleine-K?nig wrote:
> > On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> > > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > > > Based of Matt Evans's PPC64 implementation.
> > > Note that it's fine to have the JIT generating ARM code, even if =
the rest
> > > if the kernel is Thumb-2.  This would only start to cause problem=
s if we
> > > want to do things like set kprobes in the JITted code, or unwind =
out of
> > > the JITted code.
> > or use a CPU that doesn't speak ARM (e.g. v7M)
>=20
> Indeed... I was assuming though that that would be out of scope for t=
he
> first iteration of this code.
Right, depending on !THUMB2 is fine. Only generating ARM code with
THUMB2=3Dy is not.

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
