From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Tue, 18 Mar 2014 07:01:38 -0700
Message-ID: <1395151298.9114.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
	 <1395060178-11833-37-git-send-email-pablo@netfilter.org>
	 <1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140318144616.0c568cbb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140318144616.0c568cbb@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-18 at 14:46 +0100, Jesper Dangaard Brouer wrote:

> Hehe, I actually also pointed this out during my internal review, but
> we never gotten around to fixing this.

BTW, sizeof(spinlock_t) can be 2 bytes, if NR_CPUS is below 128 on x86

So whole hash table fits in a single cache line.


