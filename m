From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next v2] ipip: dereferencing an ERR_PTR in
 ip_tunnel_init_net()
Date: Tue, 20 Aug 2013 23:33:01 -0700 (PDT)
Message-ID: <20130820.233301.985050199020241179.davem@davemloft.net>
References: <1376917088.4226.50.camel@edumazet-glaptop>
	<20130819222307.GA3622@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130819222307.GA3622@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 20 Aug 2013 01:23:07 +0300

> The __ip_tunnel_create() function returns an ERR_PTR on error so we need
> to check for that before dereferencing.  This bug was added in commit
> 6c742e714d8c2 ("ipip: add x-netns support").
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: Eric Dumazet said v1 patch looked racy and suggested the v2 fix.
> 

This doesn't apply cleanly, you'll need to respin it.
