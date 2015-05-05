From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 1/5] net: sched: replace NCLS macro with tc_nocls
 bit flag
Date: Tue, 05 May 2015 19:15:20 -0400 (EDT)
Message-ID: <20150505.191520.389763061968997192.davem@davemloft.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
	<1430765318-13788-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933301AbbEEXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:15:25 -0400
In-Reply-To: <1430765318-13788-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  4 May 2015 20:48:34 +0200

> @@ -566,8 +567,10 @@ struct sk_buff {
>  				fclone:2,
>  				peeked:1,
>  				head_frag:1,
> +#ifdef CONFIG_NET_CLS_ACT
> +				tc_nocls:1,
> +#endif
>  				xmit_more:1;
> -	/* one bit hole */
>  	kmemcheck_bitfield_end(flags1);

You can now remove the "one bit hole" comment?
