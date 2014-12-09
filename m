From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next][V2] net: avoid to call skb_queue_len again
Date: Tue, 09 Dec 2014 17:03:54 -0500 (EST)
Message-ID: <20141209.170354.167467937120673496.davem@davemloft.net>
References: <1418002975-15271-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	sergei.shtylyov@cogentembedded.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbaLIWD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:03:57 -0500
In-Reply-To: <1418002975-15271-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon,  8 Dec 2014 09:42:55 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> the queue length of sd->input_pkt_queue has been put into qlen,
> and impossible to change, since hold the lock
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
