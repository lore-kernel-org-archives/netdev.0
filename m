From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/27] atheros: atlx: Use setup_timer
Date: Tue, 30 Dec 2014 18:35:23 -0500 (EST)
Message-ID: <20141230.183523.1317268892939288322.davem@davemloft.net>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
	<1419604558-29743-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, kernel-janitors@vger.kernel.org,
	chris.snook@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Fri, 26 Dec 2014 15:35:34 +0100

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
