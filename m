From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] netfilter fixes for 3.9-rc
Date: Wed, 20 Mar 2013 10:25:22 -0400 (EDT)
Message-ID: <20130320.102522.1602310574602201267.davem@davemloft.net>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Wed, 20 Mar 2013 11:49:27 +0100

> The following patchset contains 7 Netfilter/IPVS fixes for 3.9-rc, they are:
> 
> * Restrict IPv6 stateless NPT targets to the mangle table. Many users are
>   complaining that this target does not work in the nat table, which is the
>   wrong table for it, from Florian Westphal.
> 
> * Fix possible use before initialization in the netns init path of several
>   conntrack protocol trackers (introduced recently while improving conntrack
>   netns support), from Gao Feng.
> 
> * Fix incorrect initialization of copy_range in nfnetlink_queue, spotted
>   by Eric Dumazet during the NFWS2013, patch from myself.
> 
> * Fix wrong calculation of next SCTP chunk in IPVS, from Julian Anastasov.
> 
> * Remove rcu_read_lock section in IPVS while calling ipv4_update_pmtu
>   not required anymore after change introduced in 3.7, again from Julian.
> 
> * Fix SYN looping in IPVS state sync if the backup is used a real server
>   in DR/TUN modes, this required a new /proc entry to disable the director
>   function when acting as backup, also from Julian.
> 
> * Remove leftover IP_NF_QUEUE Kconfig after ip_queue removal, noted by
>   Paul Bolle.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks!
