From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Wed, 18 Oct 2017 16:45:08 -0500
Message-ID: <20171018214508.GA12295@localhost.corp.microsoft.com>
References: <cover.1508251210.git.daniel@iogearbox.net>
 <20171018132526.GC1302522@devbig577.frc2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
        ast@kernel.org, john.fastabend@gmail.com, mark.rutland@arm.com,
        richard@nod.at, sp3485@columbia.edu, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171018132526.GC1302522@devbig577.frc2.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel and Tejun,

On Wed, Oct 18, 2017 at 06:25:26AM -0700, Tejun Heo wrote:
> > Daniel Borkmann (3):
> >   mm, percpu: add support for __GFP_NOWARN flag
> 
> This looks fine.
> 

Looks good to me too.

> >   bpf: fix splat for illegal devmap percpu allocation
> >   bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations
> 
> These look okay too but if it helps percpu allocator can expose the
> maximum size / alignment supported to take out the guessing game too.
> 

I can add this once we've addressed the below if we want to.

> Also, the reason why PCPU_MIN_UNIT_SIZE is what it is is because
> nobody needed anything bigger.  Increasing the size doesn't really
> cost much at least on 64bit archs.  Is that something we want to be
> considering?
> 

I'm not sure I see the reason we can't match the minimum allocation size
with the unit size? It seems weird to arbitrate the maximum allocation
size given a lower bound on the unit size.

Thanks,
Dennis
