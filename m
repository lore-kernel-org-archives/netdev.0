From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] make netlink processing routines semi-synchronious	(inspired
 by rtnl)
Date: Mon, 01 Oct 2007 15:10:12 +0200
Message-ID: <4700F1B4.4090603@trash.net>
References: <20071001124042.GA8878@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net, tgraf@suug.ch,
	pablo@netfilter.org, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65241 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbXJANKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:10:37 -0400
In-Reply-To: <20071001124042.GA8878@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> The code in netfilter/nfnetlink.c and in ./net/netlink/genetlink.c looks
> like outdated copy/paste from rtnetlink.c. Push them into sync with the
> original.
> 

>  int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
> @@ -149,7 +137,7 @@ static int nfnetlink_rcv_msg(struct sk_b
>  #ifdef CONFIG_KMOD
>  		/* don't call nfnl_unlock, since it would reenter
>  		 * with further packet processing */
> -		__nfnl_unlock();
> +		nfnl_unlock();


That comment should be updated/deleted. Rest looks good to me.
