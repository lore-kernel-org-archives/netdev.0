From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Sat, 05 Sep 2015 21:59:05 -0700 (PDT)
Message-ID: <20150905.215905.1856210304694191648.davem@davemloft.net>
References: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  3 Sep 2015 11:50:55 +0200

> The following patchset contains Netfilter fixes for net, they are:
> 
> 1) Oneliner to restore maps in nf_tables since we support addressing registers
>    at 32 bits level.
> 
> 2) Restore previous default behaviour in bridge netfilter when CONFIG_IPV6=n,
>    oneliner from Bernhard Thaler.
> 
> 3) Out of bound access in ipset hash:net* set types, reported by Dave Jones'
>    KASan utility, patch from Jozsef Kadlecsik.
> 
> 4) Fix ipset compilation with gcc 4.4.7 related to C99 initialization of
>    unnamed unions, patch from Elad Raz.
> 
> 5) Add a workaround to address inconsistent endianess in the res_id field of
>    nfnetlink batch messages, reported by Florian Westphal.
> 
> 6) Fix error paths of CT/synproxy since the conntrack template was moved to use
>    kmalloc, patch from Daniel Borkmann.
> 
> All of them look good to me to reach 4.2, I can route this to -stable myself
> too, just let me know what you prefer.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, there was a merge conflict, please verify that I resolved it
correctly.

Thanks.
