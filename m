From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gro: Fix kcalloc argument order
Date: Sun, 27 Jan 2013 19:13:41 -0500 (EST)
Message-ID: <20130127.191341.444561143405489074.davem@davemloft.net>
References: <1359228259.2079.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359228259.2079.30.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 26 Jan 2013 11:24:19 -0800

> First number, then size.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Good catch, since this bug doesn't cause any real functional problem
I've applied the patch to net-next.

Thanks.
