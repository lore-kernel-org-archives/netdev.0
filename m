From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 18 Dec 2013 19:48:46 -0800
Message-ID: <1387424926.19078.356.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
		 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
		 <52B24D7D.6060902@windriver.com>
	 <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B26553.9070103@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=E7=8E=8B=E8=81=AA?= <xiyou.wangcong@gmail.com>,
	steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:60360 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176Ab3LSDse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 22:48:34 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so566162pbc.6
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 19:48:34 -0800 (PST)
In-Reply-To: <52B26553.9070103@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 11:17 +0800, Fan Du wrote:

> +	head = llist_del_all(&net->xfrm.xp_sk_bundles_list);
> +	llist_for_each_entry(xdst, head, xdst_llist)
> +		dst_free(&xdst->u.dst);
>   }

llist_for_each_entry_safe
