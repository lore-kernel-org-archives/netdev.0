From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2 1/4] net/core: relax BUILD_BUG_ON in
 netdev_stats_to_stats64
Date: Sun, 31 Jan 2016 13:07:04 -0500
Message-ID: <20160131180704.GA36726@redhat.com>
References: <1454178872.7627.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160130203900.GQ59058@redhat.com>
 <20160130205305.GR59058@redhat.com>
 <20160130.152635.1510710440132684620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160130.152635.1510710440132684620.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2016 at 03:26:35PM -0800, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Sat, 30 Jan 2016 15:53:05 -0500
> 
> > On Sat, Jan 30, 2016 at 03:39:01PM -0500, Jarod Wilson wrote:
> >> Ew, no, it won't work correctly on 32-bit. The for loop is going to copy
> >> data into dst from beyond the end of netdev_stats, and the range looks
> >> like it won't be right either, only half of the added stats64 space will
> >> get zeroed out. Okay, I'll fix that up correctly.
> > 
> > Completely untested as of yet, but I think something like the following
> > looks correct. I'll give it a spin as soon as I can.
> 
> Jarod, please respin your entire series as a v3 once you sort this out.

Will do. I should be able to get it tested out on a 32-bit setup Monday.

-- 
Jarod Wilson
jarod@redhat.com
