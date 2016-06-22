From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [6/6] ppc: ebpf/jit: Implement JIT compiler for extended BPF
Date: Wed, 22 Jun 2016 12:36:30 +0530
Message-ID: <20160622070630.GI8886@naverao1-tp.localdomain>
References: <908d3552b5eb240b28f70aee7c4c86e2b600aa02.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
 <3rWKtT2tSrz9t2G@ozlabs.org>
 <20160619173642.GB8886@naverao1-tp.localdomain>
 <1466465899.437.0.camel@ellerman.id.au>
 <20160621065847.GD8886@naverao1-tp.localdomain>
 <1466507043.18876.1.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466507043.18876.1.camel@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/06/21 09:04PM, Michael Ellerman wrote:
> On Tue, 2016-06-21 at 12:28 +0530, Naveen N. Rao wrote:
> > On 2016/06/21 09:38AM, Michael Ellerman wrote:
> > > On Sun, 2016-06-19 at 23:06 +0530, Naveen N. Rao wrote:
> > > > 
> > > > #include <asm/kprobes.h>
> > > > 
> > > > in bpf_jit_comp64.c
> > > > 
> > > > Can you please check if it resolves the build error?
> > > 
> > > Can you? :D
> > 
> > :)
> > Sorry, I should have explained myself better. I did actually try your 
> > config and I was able to reproduce the build error. After the above 
> > #include, that error went away, but I saw some vdso related errors. I 
> > thought I was doing something wrong and needed a different setup for 
> > that particular kernel config, which is why I requested your help in the 
> > matter. I just didn't do a good job of putting across that message...
> 
> Ah OK. Not sure why you're seeing VDSO errors?

'Cause I wasn't paying attention. I tried your .config on a LE machine.  
It works fine on BE, as it should.

> 
> > Note to self: randconfig builds *and* more time drafting emails :)
> 
> No stress. You don't need to do randconfig builds, or even build all the
> arch/powerpc/ configs, just try to do a reasonable set, something like - ppc64,
> powernv, pseries, pmac32, ppc64e.

Ok, will do.

> 
> I'm happy to catch the esoteric build failures.
> 
> > Do you want me to respin the patches?
> 
> No that's fine, I'll fix it up here.

Thanks,
Naveen
