From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Wed, 2 Nov 2011 16:24:03 -0700
Message-ID: <20111102232403.GO31337@atomide.com>
References: <4EB1CA4F.3090403@gmail.com>
 <20111102.190955.1902322759075682192.davem@davemloft.net>
 <4EB1CEC4.3090909@gmail.com>
 <20111102.191716.1682282796914825621.davem@davemloft.net>
 <20111102231917.GN31337@atomide.com>
 <4EB1D05B.6020605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4EB1D05B.6020605@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet <eric.dumazet@gmail.com> [111102 15:46]:
> On 03/11/2011 00:19, Tony Lindgren wrote:
> 
> > * David Miller <davem@davemloft.net> [111102 15:42]:
> >> c> 
> >>> The issue is calculation of skb->end, which is based upon calculated
> >>> 'size' variable.
> >>>
> >>> skb->end determines alignment of skb_shared_info, which is where the
> >>> alignment problem is occuring for Tony.
> >>
> >> Right, and SMP_CACHE_BYTES setting should save us in any case.
> >>
> >> For ARM, SMP_CACHE_BYTES seems to be set to L1_CACHE_BYTES which in
> >> turn is set via ARM_L1_CACHE_SHIFT which can be set seemingly to any
> >> value but the defaults are 5 and 6 which should be OK.
> >>
> >> So unless Tony is using a non-standard setting of ARM_L1_CACHE_SHIFT,
> >> this report is a bit mysterious.
> > 
> > This is happening at least with omap1_defconfig. In that case we have
> > ARM_L1_CACHE_SHIFT=5.
> > 
> > Regards,
> > 
> > Tony
> 
> 
> Do you use SLOB, SLUB or SLAB ?

Seems to be SLOB for omap1_defconfig.

Tony
