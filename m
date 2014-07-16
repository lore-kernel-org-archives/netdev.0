From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter/nf_tables fixes
Date: Wed, 16 Jul 2014 15:27:41 -0700 (PDT)
Message-ID: <20140716.152741.1219558548704915796.davem@davemloft.net>
References: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 15 Jul 2014 16:05:18 +0200

> The following patchset contains nf_tables fixes, they are:
> 
> 1) Fix wrong transaction handling when the table flags are not
>    modified.
> 
> 2) Fix missing rcu read_lock section in the netlink dump path, which
>    is not protected by the nfnl_lock.
> 
> 3) Set NLM_F_DUMP_INTR in the netlink dump path to indicate
>    interferences with updates.
> 
> 4) Fix 64 bits chain counters when they are retrieved from a 32 bits
>    arch, from Eric Dumazet.

Pulled, thanks a lot Pablo.
