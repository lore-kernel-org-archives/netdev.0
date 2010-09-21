From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v6] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Tue, 21 Sep 2010 17:50:40 +0200
Message-ID: <4C98D450.3070601@trash.net>
References: <1284995176-2994-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1284995176-2994-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.09.2010 17:06, schrieb Changli Gao:
> Since we don't change the tuple in the original direction, we can save it
> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_confirm()
> use.
> 
> __hash_conntrack() is split into two steps: hash_conntrack_raw() is used
> to get the raw hash, and __hash_bucket() is used to get the bucket id.
> 
> In SYN-flood case, early_drop() doesn't need to recompute the hash again.

Applied, thanks Changli.
