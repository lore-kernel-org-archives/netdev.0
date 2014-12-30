From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/27] atl1e: Use setup_timer
Date: Tue, 30 Dec 2014 18:35:16 -0500 (EST)
Message-ID: <20141230.183516.405271899216450265.davem@davemloft.net>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419604558-29743-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, kernel-janitors@vger.kernel.org,
	chris.snook@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaL3XfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 18:35:18 -0500
In-Reply-To: <1419604558-29743-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Fri, 26 Dec 2014 15:35:35 +0100

> Convert a call to init_timer and accompanying intializations of
> the timer's data and function fields to a call to setup_timer.
> 
> A simplified version of the semantic match that fixes this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression t,f,d;
> @@
> 
> -init_timer(&t);
> +setup_timer(&t,f,d);
> -t.function = f;
> -t.data = d;
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
