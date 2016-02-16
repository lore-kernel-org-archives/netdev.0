From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dmascc: Return correct error codes
Date: Tue, 16 Feb 2016 15:33:01 -0500 (EST)
Message-ID: <20160216.153301.170926451372426076.davem@davemloft.net>
References: <20160209184236.GA23644@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20160209184236.GA23644@amitoj-Inspiron-3542>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 10 Feb 2016 00:12:36 +0530

> This change has been made with the goal that kernel functions should
> return something more descriptive than -1 on failure.
> 
> A variable `err` has been introduced for storing error codes.
> 
> The return value of kzalloc on failure should return a -1 and not a
> -ENOMEM. This was found using Coccinelle. A simplified version of
> the semantic patch used is:
 ...
> Furthermore, set `err` to -ENOMEM on failure of alloc_netdev(), and to
> -ENODEV on failure of register_netdev() and probe_irq_off().
> 
> The single call site only checks that the return value is not 0,
> hence no change is required at the call site.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied to net-next, thanks.
