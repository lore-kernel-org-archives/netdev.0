From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] ROUTE: ip_rt_dump() is unecessary slow
Date: Mon, 07 Jan 2008 22:15:37 -0800 (PST)
Message-ID: <20080107.221537.178212902.davem@davemloft.net>
References: <20080107193002.df137d57.dada1@cosmosbay.com>
	<20080107.215253.250616600.davem@davemloft.net>
	<47831412.40606@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54378
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757799AbYAHGPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:15:37 -0500
In-Reply-To: <47831412.40606@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 08 Jan 2008 07:11:30 +0100

> @@ -288,15 +288,15 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>  
>  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>  {
> -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> +	struct rt_cache_iter_state *st = seq->private;
>  

Can you explain to me why this rcu_dereference() can be removed?

The rest of your patch is OK and once I understand the above
I'll add it to net-2.6, thanks!
