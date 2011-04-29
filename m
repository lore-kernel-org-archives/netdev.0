From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for April 29 (bpf_jit)
Date: Fri, 29 Apr 2011 10:21:34 -0700 (PDT)
Message-ID: <20110429.102134.193704089.davem@davemloft.net>
References: <20110429131940.4f4c938f.sfr@canb.auug.org.au>
	<20110429092632.26ff1e53.randy.dunlap@oracle.com>
	<1304097558.2686.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1304097558.2686.6.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Apr 2011 19:19:18 +0200

> [PATCH net-next-2.6] bpf: depends on MODULES
> 
> module_alloc() and module_free() are available only if CONFIG_MODULES=y
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

Perhaps we can solve these things by seperating out the dependency,
via "CONFIG_MODULE_ALLOC" and making things like KPROBES and
BPF 'select' it.
