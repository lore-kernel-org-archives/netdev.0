From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Wed, 22 May 2013 13:16:01 -0700
Message-ID: <1369253761.3301.355.camel@edumazet-glaptop>
References: <1368068665.13473.81.camel@edumazet-glaptop>
	 <1369244868.3301.343.camel@edumazet-glaptop>
	 <1369246816.2143.84.camel@joe-AO722>
	 <1369250772.3301.349.camel@edumazet-glaptop>
	 <1369252624.2143.103.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369252624.2143.103.camel@joe-AO722>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-22 at 12:57 -0700, Joe Perches wrote:

> Ahh, nice.
> 
> It might also be nice to mark it if ever more than a u16
> brace/flock/coven/cluster worth of cpus become feasible
> as it seems int is used almost everywhere else.

It seems Linus hates cpu_t or whatever_t

Thats why we have u16 everywhere to code cpu numbers, and why we use
"unsigned long" for jiffies.

Check include/linux/netdevice.h for numerous examples

So far, I believe linux supports at most 4096 cpus.


