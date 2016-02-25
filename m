From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: tulip: Use setup_timer()
Date: Thu, 25 Feb 2016 16:52:06 -0500 (EST)
Message-ID: <20160225.165206.1865735563237444924.davem@davemloft.net>
References: <20160224135749.GA14342@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20160224135749.GA14342@amitoj-Inspiron-3542>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 24 Feb 2016 19:27:49 +0530

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
