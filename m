From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xtables: stackptr should be percpu
Date: Mon, 31 May 2010 15:22:24 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1005311519340.25402@obet.zrqbmnf.qr>
References: <1275303998-2435-1-git-send-email-dfeng@redhat.com>  <alpine.LSU.2.01.1005311350580.31799@obet.zrqbmnf.qr> <1275311580.3291.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Xiaotian Feng <dfeng@redhat.com>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275311580.3291.44.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2010-05-31 15:13, Eric Dumazet wrote:
>
>All cpus share a single cache line for their 'stackptr' storage,
>introduced in commit f3c5c1bfd4
>
>This is a stable candidate (2.6.34)

Stackptr was first introduced for 2.6.35-rcX.

>+	i->stackptr = alloc_percpu(unsigned int);
> 	if (i->stackptr == NULL)
> 		return -ENOMEM;
>-	memset(i->stackptr, 0, size);
> 
> 	size = sizeof(void **) * nr_cpu_ids;
> 	if (size > PAGE_SIZE)

Are alloc_percpu areas cleared?

Acked-By: Jan Engelhardt <jengelh@medozas.de>

