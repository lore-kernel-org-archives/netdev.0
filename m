From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: Add skb_unclone() helper function.
Date: Thu, 14 Feb 2013 16:22:49 -0800
Message-ID: <1360887769.6884.63.camel@edumazet-glaptop>
References: <1360871089-2020-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com, mirqus@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:56730 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935133Ab3BOAWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:22:52 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so1259077dak.30
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:22:51 -0800 (PST)
In-Reply-To: <1360871089-2020-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 11:44 -0800, Pravin B Shelar wrote:
> This function will be used in next GRE_GSO patch. This patch does
> not change any functionality.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/ppp/ppp_generic.c           |    3 +--
>  include/linux/skbuff.h                  |   10 ++++++++++
>  net/ipv4/ah4.c                          |    3 +--
>  net/ipv4/ip_fragment.c                  |    2 +-
>  net/ipv4/tcp_output.c                   |    2 +-
>  net/ipv4/xfrm4_input.c                  |    2 +-
>  net/ipv4/xfrm4_mode_tunnel.c            |    3 +--
>  net/ipv6/ah6.c                          |    3 +--
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
>  net/ipv6/reassembly.c                   |    2 +-
>  net/ipv6/xfrm6_mode_tunnel.c            |    3 +--
>  net/sched/act_ipt.c                     |    6 ++----
>  net/sched/act_pedit.c                   |    3 +--
>  13 files changed, 23 insertions(+), 21 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
