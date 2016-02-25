From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] forcedeth: Use setup_timer()
Date: Thu, 25 Feb 2016 16:52:12 -0500 (EST)
Message-ID: <20160225.165212.810586246772388375.davem@davemloft.net>
References: <20160224135801.GA14387@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224135801.GA14387@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 24 Feb 2016 19:28:01 +0530

> Convert a call to init_timer and accompanying intializations of
> the timer's data and function fields to a call to setup_timer.
> 
> The Coccinelle semantic patch that fixes this problem is
> as follows:
>  
> // <smpl>
> @@
> expression t,f,d;
> @@
> 
> -init_timer(&t);
> +setup_timer(&t,f,d);
> -t.data = d;
> -t.function = f;
> // </smpl>
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
