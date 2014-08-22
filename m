From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: Use time_after_eq
Date: Fri, 22 Aug 2014 12:28:55 -0700 (PDT)
Message-ID: <20140822.122855.2088415547687197411.davem@davemloft.net>
References: <20140820175009.GA4316@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140820175009.GA4316@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Wed, 20 Aug 2014 23:20:09 +0530

> The functions time_before, time_before_eq, time_after, and time_after_eq
> are more robust for comparing jiffies against other values.
> 
> A simplified version of the Coccinelle semantic patch making this change
> is as follows:
> 
> @change@
> expression E1,E2;
> @@
> - (jiffies - E1) >= E2
> + time_after_eq(jiffies, E1+E2)
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
