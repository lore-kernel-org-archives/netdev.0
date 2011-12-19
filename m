From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 19:14:01 +0200
Message-ID: <20111219171401.GA1732@swarm.cs.pub.ro>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219151958.GU24496@pengutronix.de>
 <20111219152418.GF2031@linaro.org>
 <20111219153338.GV24496@pengutronix.de>
 <20111219155252.GG2031@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Dave Martin <dave.martin@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58100 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab1LSROK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 12:14:10 -0500
Received: by eekc4 with SMTP id c4so5645288eek.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 09:14:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111219155252.GG2031@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Dec 19, 2011 at 03:52:52PM +0000, Dave Martin wrote:
> On Mon, Dec 19, 2011 at 04:33:38PM +0100, Uwe Kleine-K?nig wrote:
> > Hello,
> > 
> > On Mon, Dec 19, 2011 at 03:24:18PM +0000, Dave Martin wrote:
> > > On Mon, Dec 19, 2011 at 04:19:58PM +0100, Uwe Kleine-K?nig wrote:
> > > > On Mon, Dec 19, 2011 at 12:50:21PM +0000, Dave Martin wrote:
> > > > > On Mon, Dec 19, 2011 at 09:40:30AM +0100, Mircea Gherzan wrote:
> > > > > > Based of Matt Evans's PPC64 implementation.
> > > > > Note that it's fine to have the JIT generating ARM code, even if the rest
> > > > > if the kernel is Thumb-2.  This would only start to cause problems if we
> > > > > want to do things like set kprobes in the JITted code, or unwind out of
> > > > > the JITted code.
> > > > or use a CPU that doesn't speak ARM (e.g. v7M)
> > > 
> > > Indeed... I was assuming though that that would be out of scope for the
> > > first iteration of this code.
> > Right, depending on !THUMB2 is fine. Only generating ARM code with
> > THUMB2=y is not.
> 
> The kernel doesn't support v7-M upstream though.  CONFIG_THUMB2_KERNEL=y
> doesn't mean that there is no ARM code present -- there _is_ ARM code in
> the kernel image even with this option (though not very much).

What about relying at runtime on bits[3:0] of ID_PFR0? And this only for
ARMv7.

Are there any other ARM cores of interest that do _not_ support the ARM
instruction set?

Thanks,
Mircea
