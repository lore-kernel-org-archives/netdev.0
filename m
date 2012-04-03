From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Wed, 04 Apr 2012 08:11:42 +1000
Message-ID: <1333491102.3040.12.camel@pasglop>
References: <4F75CA89.4010709@googlemail.com>
	 <4F75D2A5.7060407@googlemail.com>
	 <20120403.180302.342779808900865443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, matt@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403.180302.342779808900865443.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-03 at 18:03 -0400, David Miller wrote:

> > Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
> > 
> > I have only compile tested this, -ENOHARDWARE.
> > Can someone with more powerpc kung-fu review and maybe test this?
> > Esp. powerpc asm is not my strong point. I think i botched the
> > stack frame in the call setup. Help?
> 
> I'm not applying this until a powerpc person tests it.
> 
> Also, we have an ARM JIT in the tree which probably needs to
> be fixed similarly.

Matt's having a look at powerpc

Cheers,
Ben.
