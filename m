From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] netfilter fixes for 3.10-rc3
Date: Thu, 30 May 2013 16:39:00 -0700 (PDT)
Message-ID: <20130530.163900.728264038534322099.davem@davemloft.net>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 29 May 2013 18:03:08 +0200

> The following patchset contains Netfilter/IPVS fixes for 3.10-rc3,
> they are:
> 
> * fix xt_addrtype with IPv6, from Florian Westphal. This required
>   a new hook for IPv6 functions in the netfilter core to avoid
>   hard dependencies with the ipv6 subsystem when this match is
>   only used for IPv4.
> 
> * fix connection reuse case in IPVS. Currently, if an reused
>   connection are directed to the same server. If that server is
>   down, those connection would fail. Therefore, clear the
>   connection and choose a new server among the available ones.
> 
> * fix possible non-nul terminated string sent to user-space if
>   ipt_ULOG is used as the default netfilter logging stub, from
>   Chen Gang.
> 
> * fix mark logging of IPv6 packets in xt_LOG, from Michal Kubecek.
>   This bug has been there since 2.6.26.
> 
> * Fix breakage ip_vs_sh due to incorrect structure layout for
>   RCU, from Jan Beulich.
 ...
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo!
