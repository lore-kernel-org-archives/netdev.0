From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch 2/2] ipvs: Syncrhonise Closing of Connections
Date: Fri, 2 Nov 2007 01:36:07 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0711020119580.2992@u.domain.uli>
References: <20071101092818.083169402@vergenet.net> <20071101093022.688977274@vergenet.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	"Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Graeme Fowler <graeme@graemef.net>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:4211 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754412AbXKAXls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 19:41:48 -0400
In-Reply-To: <20071101093022.688977274@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 1 Nov 2007, Simon Horman wrote:

> --- net-2.6.orig/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:17:55.000000000 +0900
> +++ net-2.6/net/ipv4/ipvs/ip_vs_sync.c	2007-11-01 18:20:30.000000000 +0900
> @@ -332,7 +332,7 @@ static void ip_vs_process_message(const 
>  					    s->daddr, s->dport,
>  					    flags, dest);
>  			if (dest)

	Is that correct? Sorry, I was flooded with different versions
of this patch and I'm not sure if it is the final one.

> -				atomic_dec(&dest->refcnt);
> +				ip_vs_dest_get(dest);
>  			if (!cp) {
>  				IP_VS_ERR("ip_vs_conn_new failed\n");
>  				return;

Regards

--
Julian Anastasov <ja@ssi.bg>
