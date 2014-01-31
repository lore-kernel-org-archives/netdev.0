From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Thu, 30 Jan 2014 18:16:55 -0800
Message-ID: <1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf>
	 <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1401181101220.579@dtop>
	 <alpine.DEB.2.02.1401292301070.5905@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: dormando <dormando@rydia.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401292301070.5905@dtop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-01-29 at 23:05 -0800, dormando wrote:

> We hit the routing code fairly hard. Any hints for what to look at or how
> to instrument it? Or if it's fixed already? It's a real pain to iterate
> since it takes ~30 days to crash, usually. Sometimes.

I really wonder... it looks like a possible in SLUB. (might be already
fixed)

Could you try using SLAB instead ?
