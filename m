From: David Miller <davem@davemloft.net>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 10 May 2010 09:12:57 -0700 (PDT)
Message-ID: <20100510.091257.51273494.davem@davemloft.net>
References: <1272865436.2173.182.camel@edumazet-laptop>
	<20100502.225509.233880079.davem@davemloft.net>
	<4BE8290A.2080707@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Valdis.Kletnieks@vt.edu,
	akpm@linux-foundation.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BE8290A.2080707@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 10 May 2010 17:40:58 +0200

> I queued this patch in nf-next, the only reason why I haven't
> submitted it yet is that I was unable to get git to cleanly export
> only the proper set of patches meant for -next due to a few merges,
> it insists on including 5 patches already merged upstream. If you
> don't mind ignoring the first 5 patches in the series, I'll send a
> pull request tonight.

Something like "git format-patch origin" doesn't avoid those upstream
commits?  Weird...

Another trick is to specify a commit range using triple-dot "..."
notation, such as "origin...master"
