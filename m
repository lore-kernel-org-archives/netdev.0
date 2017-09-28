From: Tejun Heo <tj@kernel.org>
Subject: Re: EBPF-triggered WARNING at mm/percpu.c:1361 in v4-14-rc2
Date: Thu, 28 Sep 2017 07:53:02 -0700
Message-ID: <20170928145302.GE15129@devbig577.frc2.facebook.com>
References: <20170928112727.GA11310@leverpostej>
 <59CD093A.6030201@iogearbox.net>
 <20170928144538.GA32487@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        netdev@vger.kernel.org, syzkaller@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Christoph Lameter <cl@linux.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170928144538.GA32487@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Sep 28, 2017 at 03:45:38PM +0100, Mark Rutland wrote:
> > Perhaps the pr_warn() should be ratelimited; or could there be an
> > option where we only return NULL, not triggering a warn at all (which
> > would likely be what callers might do anyway when checking against
> > PCPU_MIN_UNIT_SIZE and then bailing out)?
> 
> Those both make sense to me; checking __GFP_NOWARN should be easy
> enough.

That also makes sense.

> Just to check, do you think that dev_map_alloc() should explicitly test
> the size against PCPU_MIN_UNIT_SIZE, prior to calling pcpu_alloc()?

But let's please not do this.

Thanks.

-- 
tejun
