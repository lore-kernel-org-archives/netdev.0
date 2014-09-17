From: mroos@linux.ee
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Wed, 17 Sep 2014 15:43:54 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1409171529350.26961@adalberg.ut.ee>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee> <20140916101704.GA3792@hmsreliant.think-freely.org> <20140916.162923.605101746131407931.davem@davemloft.net> <20140917102701.GA5699@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, steffen@klassert.de,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140917102701.GA5699@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Shit, you're right, sorry about that.  Its odd, I'm running it here, and its not 
> causing problems, but thats obviously wrong.  Meelis, please add the above fix
> to your test and confirm that it sovles the problem.  If you could keep the
> previous patch in place too that would be great, as we should probably add the
> dma error checking anyway.
> 
> 
> [PATCH] 3c59x: Fix bad offset spec in skb_frag_dma_map

Tested 2 variants: only this patch (backported to old state) and both 
patches together.

Both work fine.

-- 
Meelis Roos (mroos@linux.ee)
