From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter/IPVS fixes for net
Date: Tue, 01 Oct 2013 12:39:58 -0400 (EDT)
Message-ID: <20131001.123958.666337591702028107.davem@davemloft.net>
References: <1380618511-6109-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380618511-6109-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  1 Oct 2013 11:08:25 +0200

> The following patchset contains Netfilter/IPVS fixes for your net
> tree, they are:
> 
> * Fix BUG_ON splat due to malformed TCP packets seen by synproxy, from
>   Patrick McHardy.
> 
> * Fix possible weight overflow in lblc and lblcr schedulers due to
>   32-bits arithmetics, from Simon Kirby.
> 
> * Fix possible memory access race in the lblc and lblcr schedulers,
>   introduced when it was converted to use RCU, two patches from
>   Julian Anastasov.
> 
> * Fix hard dependency on CPU 0 when reading per-cpu stats in the
>   rate estimator, from Julian Anastasov.
> 
> * Fix race that may lead to object use after release, when invoking
>   ipvsadm -C && ipvsadm -R, introduced when adding RCU, from Julian
>   Anastasov.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
