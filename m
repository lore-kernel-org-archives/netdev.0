From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sch_htb: let skb->priority refer to non-leaf class
Date: Tue, 21 Jan 2014 14:36:41 -0800 (PST)
Message-ID: <20140121.143641.295542315649549669.davem@davemloft.net>
References: <1389953999.4698.18.camel@azathoth.dev.smoothwall.net>
	<52D927CD.4080403@cogentembedded.com>
	<1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, hadi@mojatatu.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: harry.mason@smoothwall.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaAUWgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:36:42 -0500
In-Reply-To: <1389964952.4698.20.camel@azathoth.dev.smoothwall.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harry Mason <harry.mason@smoothwall.net>
Date: Fri, 17 Jan 2014 13:22:32 +0000

> If the class in skb->priority is not a leaf, apply filters from the
> selected class, not the qdisc. This lets netfilter or user space
> partially classify the packet.
> 
> Signed-off-by: Harry Mason <harry.mason@smoothwall.net>

Can I please get some reviews of this patch?

Thanks.
