From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip_conntrack_helper_pptp.c: fix sstate/cstate typo
Date: Fri, 26 May 2006 16:38:43 +0200
Message-ID: <447712F3.20008@trash.net>
References: <20060526122342.GB7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Harald Welte <laforge@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:28811 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750828AbWEZOip
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:38:45 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060526122342.GB7267@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
> --- a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
> +++ b/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
> @@ -469,8 +469,8 @@ pptp_inbound_pkt(struct sk_buff **pskb,
>  			DEBUGP("%s but no session\n", pptp_msg_name[msg]);
>  			break;
>  		}
> -		if (info->sstate != PPTP_CALL_IN_REP
> -		    && info->sstate != PPTP_CALL_IN_CONF) {
> +		if (info->cstate != PPTP_CALL_IN_REP
> +		    && info->cstate != PPTP_CALL_IN_CONF) {
>  			DEBUGP("%s but never sent IN_CALL_REPLY\n",
>  				pptp_msg_name[msg]);
>  			break;


Looks correct to me, but I'm not that familiar with the code.
Harald, do you want me to apply this?
