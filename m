From: David Miller <davem@davemloft.net>
Subject: Re: [Resent] [PATCH 1/2] udp: Fix the SNMP counter of
 UDP_MIB_INDATAGRAMS
Date: Sun, 02 Nov 2008 23:46:25 -0800 (PST)
Message-ID: <20081102.234625.135160979.davem@davemloft.net>
References: <490C1CA7.3070201@cn.fujitsu.com>
	<20081101.213529.60503932.davem@davemloft.net>
	<490E5DB5.4020407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41835
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754395AbYKCHqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 02:46:50 -0500
In-Reply-To: <490E5DB5.4020407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 03 Nov 2008 10:11:01 +0800

> @@ -158,6 +159,8 @@ try_again:
>  	else if (copied < ulen)
>  		msg->msg_flags |= MSG_TRUNC;
>  +	is_udp4 = (skb->protocol == htons(ETH_P_IP));
> +

I'm still getting these corruptions.

I will investigate the problem and submit a bug report for Mew if
necessary.

I'll pull the patches out of patchwork since they look OK there.

However, this is not optimal for me until that Mew issue gets fixed,
so for future submissions could you not use format=flowed?  Or at
least put the patch part in an attachment.

Thank you.

