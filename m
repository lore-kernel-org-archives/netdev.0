From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 10/21] netfilter: ipset: Return bool values instead of
 int
Date: Mon, 18 May 2015 09:31:30 -0700
Message-ID: <1431966690.2870.27.camel@perches.com>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
	 <1431966324-4494-11-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Sergey Popovich <popovich_sergei@mail.ua>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431966324-4494-11-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-18 at 18:25 +0200, Pablo Neira Ayuso wrote:
> From: Sergey Popovich <popovich_sergei@mail.ua>
[]
> diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
[]
> @@ -56,15 +56,15 @@ hash_ip4_data_equal(const struct hash_ip4_elem *e1,
>  	return e1->ip == e2->ip;
>  }
>  
> -static inline bool
> +static bool

It's nicer when a change like this, which doesn't fit the
subject description, is explained or described in the commit log.


