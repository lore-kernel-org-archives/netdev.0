From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: gre: fix wrong skb->protocol in WCCP
Date: Mon, 24 Nov 2014 16:11:27 -0500 (EST)
Message-ID: <20141124.161127.70670502752718043.davem@davemloft.net>
References: <1416824715-28733-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	yuri.chislov@gmail.com, xeb@mail.ru
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaKXVL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:11:29 -0500
In-Reply-To: <1416824715-28733-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 24 Nov 2014 11:25:15 +0100

> From: Yuri Chislov <yuri.chislov@gmail.com>
> 
> When using GRE redirection in WCCP, it sets the wrong skb->protocol,
> that is, ETH_P_IP instead of ETH_P_IPV6 for the encapuslated traffic.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Cc: Dmitry Kozlov <xeb@mail.ru>
> Signed-off-by: Yuri Chislov <yuri.chislov@gmail.com>
> Tested-by: Yuri Chislov <yuri.chislov@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Also checked back with Dmitry, it was a copy-paste error from the
>  IPv4 implementation.

Good catch, applied, thanks Faniel.
