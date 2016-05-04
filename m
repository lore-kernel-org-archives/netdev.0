From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] block/drbd: use nla_put_u64_64bit()
Date: Wed, 04 May 2016 12:50:57 -0400 (EDT)
Message-ID: <20160504.125057.1606520320212390037.davem@davemloft.net>
References: <20160504090529.GJ16459@soda.linbit>
	<5729EFBC.7040002@6wind.com>
	<1462372026.5535.344.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462372026.5535.344.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 May 2016 07:27:06 -0700

> kernel was fine, and most user land apps were fine as well.

Userland should really not have to deal with garbage like this.

And because it quietly works just fine on x86-64, nothing makes
sure that applications will universally get this right anyways.

Better to align things properly and magically all of these issues
simply disappear.
