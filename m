From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Wed, 21 Dec 2011 10:07:17 -0500 (EST)
Message-ID: <alpine.LFD.2.02.1112211006430.2907@xanadu.home>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
 <alpine.LFD.2.02.1112191231520.2907@xanadu.home>
 <20111221144346.GB3229@swarm.cs.pub.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:59923 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1LUPHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 10:07:19 -0500
Received: from xanadu.home ([66.130.28.92]) by VL-VM-MR004.ip.videotron.ca
 (Oracle Communications Messaging Exchange Server 7u4-22.01 64bit (built Apr 21
 2011)) with ESMTP id <0LWK00JUG75V2L30@VL-VM-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 21 Dec 2011 10:03:32 -0500 (EST)
In-reply-to: <20111221144346.GB3229@swarm.cs.pub.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Dec 2011, Mircea Gherzan wrote:

> On Mon, Dec 19, 2011 at 12:42:49PM -0500, Nicolas Pitre wrote:
> > On Mon, 19 Dec 2011, Mircea Gherzan wrote:
> > 
> > > +static inline void _emit(int cond, u32 inst, struct jit_ctx *ctx)
> > > +{
> > > +	if (ctx->target != NULL)
> > > +		ctx->target[ctx->idx] = inst | (cond << 28);
> > > +
> > > +	ctx->idx++;
> > > +}
> > 
> > You might consider the patch titled "ARM: Add generic instruction opcode 
> > manipulation helpers" that Dave Martin just posted and rely on it to 
> > make your code compatible with BE8 mode as well.
> 
> That patch is not in devel-stable and I don't want to introduce further
> dependencies for the time being. Once both patches are in mainline, I
> will take a look.

Fair enough.


Nicolas
