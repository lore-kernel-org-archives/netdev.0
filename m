From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] netfilter: move generic hook infrastructure into
 net/core/hooks.c
Date: Thu, 30 Apr 2015 01:59:32 +0200
Message-ID: <20150429235932.GC7025@acer.localdomain>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-5-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430333589-4940-5-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.04, Pablo Neira Ayuso wrote:
> This patch moves the very basic hook infrastructure into net/core/hooks.c
> and it also adds a new CONFIG_NETFILTER_HOOKS kconfig switch.
> 
> The idea is to allow CONFIG_NETFILTER_HOOKS selection from qdisc ingress
> without depending on the full Netfilter layer 3 hooks (ie. CONFIG_NETFILTER).
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  MAINTAINERS                      |    1 +
>  include/linux/netfilter.h        |   96 +----------------------
>  include/linux/netfilter_hooks.h  |  117 ++++++++++++++++++++++++++++
>  include/net/netfilter/nf_queue.h |    1 +
>  net/Kconfig                      |    7 ++
>  net/core/Makefile                |    1 +
>  net/core/dev.c                   |    2 +
>  net/core/hooks.c                 |  159 ++++++++++++++++++++++++++++++++++++++
>  net/netfilter/core.c             |  149 +----------------------------------
>  net/netfilter/nf_internals.h     |    2 -

Just a general comment, still reviewing in detail, but it would be preferrable
to have a diff using -M -C to have the rename seen in the diff itself.

Cheers,
Patrick
