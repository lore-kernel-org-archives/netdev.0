From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: add cell concept to simulate special MAC
 behavior
Date: Mon, 12 Dec 2011 19:01:32 -0500 (EST)
Message-ID: <20111212.190132.2127710068935598402.davem@davemloft.net>
References: <1323562110-13865-1-git-send-email-hagen@jauu.net>
	<1323562314-14033-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, fw@strlen.de
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557Ab1LMABo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 19:01:44 -0500
In-Reply-To: <1323562314-14033-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Sun, 11 Dec 2011 01:11:54 +0100

> @@ -568,6 +585,12 @@ static void get_rate(struct Qdisc *sch, const struct nlattr *attr)
>  	const struct tc_netem_rate *r = nla_data(attr);
>  
>  	q->rate = r->rate;
> +	q->packet_overhead = r->packet_overhead;
> +	q->cell_size = r->cell_size;
> +	if (q->cell_size)
> +		q->cell_size_reciprocal = reciprocal_value(q->cell_size);
> +	q->cell_overhead = r->cell_overhead;
>  }
>  
>  static int get_loss_clg(struct Qdisc *sch, const struct nlattr *attr)

This patch is corrupted.  The hunk header here says there should be 6 lines
of content before the change and 12 lines afterwards, but there are only 11
lines of content afterwards.

Please fix this up and resubmit.
