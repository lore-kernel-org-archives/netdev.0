From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.39-rc: WARNING: at __ip_select_ident+0xd3/0xf0()
Date: Wed, 23 Mar 2011 12:18:31 -0700 (PDT)
Message-ID: <20110323.121831.70184496.davem@davemloft.net>
References: <AANLkTinacRCOx+z02n1OwBjGfVL5itzZs7Jqv_4PRXZK@mail.gmail.com>
	<1300873779.3063.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300873779.3063.39.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Mar 2011 10:49:39 +0100

> [PATCH] ipv4: fix ip_rt_update_pmtu()
> 
> commit 2c8cec5c10bc (Cache learned PMTU information in inetpeer) added
> an extra inet_putpeer() call in ip_rt_update_pmtu().
> 
> This results in various problems, since we can free one inetpeer, while
> it is still in use.
> 
> Ref: http://www.spinics.net/lists/netdev/msg159121.html
> 
> Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
