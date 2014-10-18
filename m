From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a potential use after free in gre_offload.c
Date: Sat, 18 Oct 2014 13:07:36 -0400 (EDT)
Message-ID: <20141018.130736.1862152251359862845.davem@davemloft.net>
References: <1413624364-12944-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weichunc@plumgrid.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaJRRHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:07:37 -0400
In-Reply-To: <1413624364-12944-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sat, 18 Oct 2014 17:26:04 +0800

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

Applied.
