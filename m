From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ipv4: netfilter: Comparison to NULL could be written
Date: Sat, 01 Apr 2017 06:05:59 -0700
Message-ID: <1491051959.27353.40.camel@perches.com>
References: <20170401083520.GA2037@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>,
        pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170401083520.GA2037@arushi-HP-Pavilion-Notebook>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-04-01 at 14:05 +0530, Arushi Singhal wrote:
> Fixed coding style for null comparisons to be more
> consistant with the rest of the kernel coding style.

typo: consistent and trivia:

> diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
[]
> @@ -653,7 +653,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
>  	countersize = sizeof(struct xt_counters) * private->number;
>  	counters = vzalloc(countersize);
>  
> -	if (counters == NULL)
> +	if (!counters)
>  		return ERR_PTR(-ENOMEM);

This could also remove the blank link above the test.

