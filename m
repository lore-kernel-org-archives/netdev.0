From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] Netfilter/IPVS updates for net-next
Date: Thu, 06 Jun 2013 02:03:28 -0700 (PDT)
Message-ID: <20130606.020328.539086240132260496.davem@davemloft.net>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed,  5 Jun 2013 22:40:21 +0200

> The following patchset contains the first batch of
> Netfilter/IPVS updates for your net-next tree, they are:
> 
> * Three patches with improvements and code refactorization
>   for nfnetlink_queue, from Florian Westphal.
> 
> * FTP helper now parses replies without brackets, as RFC1123
>   recommends, from Jeff Mahoney.
> 
> * Rise a warning to tell everyone about ULOG deprecation,
>   NFLOG has been already in the kernel tree for long time
>   and supersedes the old logging over netlink stub, from
>   myself.
> 
> * Don't panic if we fail to load netfilter core framework,
>   just bail out instead, from myself.
> 
> * Add cond_resched_rcu, used by IPVS to allow rescheduling
>   while walking over big hashtables, from Simon Horman.
> 
> * Change type of IPVS sysctl_sync_qlen_max sysctl to avoid
>   possible overflow, from Zhang Yanfei.
> 
> * Use strlcpy instead of strncpy to skip zeroing of already
>   initialized area to write the extension names in ebtables,
>   from Chen Gang.
> 
> * Use already existing per-cpu notrack object from xt_CT,
>   from Eric Dumazet.
> 
> * Save explicit socket lookup in xt_socket now that we have
>   early demux, also from Eric Dumazet.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Pulled, thanks!
