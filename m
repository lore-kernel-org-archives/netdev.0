From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 12:43:40 +1000
Message-ID: <1335753820.20866.27.camel@pasglop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F75D2A5.7060407@googlemail.com>
	 <20120403.180302.342779808900865443.davem@davemloft.net>
	 <1333491102.3040.12.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59357 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754961Ab2D3Cn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Apr 2012 22:43:58 -0400
In-Reply-To: <1333491102.3040.12.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-04 at 08:11 +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2012-04-03 at 18:03 -0400, David Miller wrote:
> 
> > > Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
> > > 
> > > I have only compile tested this, -ENOHARDWARE.
> > > Can someone with more powerpc kung-fu review and maybe test this?
> > > Esp. powerpc asm is not my strong point. I think i botched the
> > > stack frame in the call setup. Help?
> > 
> > I'm not applying this until a powerpc person tests it.
> > 
> > Also, we have an ARM JIT in the tree which probably needs to
> > be fixed similarly.
> 
> Matt's having a look at powerpc

Ok, he hasn't so I'll dig a bit.

No obvious wrongness (but I'm not very familiar with bpf), though I do
have a comment: sk_negative_common() and bpf_slow_path_common() should
be made one and single macro which takes the fallback function as an
argument.

I'll mess around & try to test using Jan test case & will come back
with an updated patch.

Cheers,
Ben.
