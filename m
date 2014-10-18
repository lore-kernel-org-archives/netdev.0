From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix a potential use after free in gre_offload.c
Date: Sat, 18 Oct 2014 08:47:15 -0700
Message-ID: <1413647235.27176.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413624364-12944-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weichunc@plumgrid.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39664 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaJRPrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 11:47:17 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so2453360pdi.10
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 08:47:16 -0700 (PDT)
In-Reply-To: <1413624364-12944-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-10-18 at 17:26 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() may change skb->data and make greh pointer oboslete;
> so need to reassign greh;
> but since first calling pskb_may_pull already ensured that skb->data
> has enough space for greh, so move the reference of greh before second
> calling pskb_may_pull(), to avoid reassign greh.
> 
> Fixes: 7a7ffbabf9("ipv4: fix tunneled VM traffic over hw VXLAN/GRE GSO NIC")
> Cc: Wei-Chun Chao <weichunc@plumgrid.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
