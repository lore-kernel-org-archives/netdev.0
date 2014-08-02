From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Use managed interfaces
Date: Sat, 02 Aug 2014 16:41:26 -0700 (PDT)
Message-ID: <20140802.164126.415120903689434848.davem@davemloft.net>
References: <20140801153003.GA11527@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801153003.GA11527@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 1 Aug 2014 21:00:03 +0530

> This patch introduces the use of managed interfaces like
> devm_ioremap_resource and does away with the calls to free the
> allocated memory in the probe and remove functions. Also, some
> labels and variable are done away with. This fixes a bug as there
> was a missing release_mem_region in the remove function.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

I adjusted the Subject subsystem prefix to "net: dnet:" and applied
this, thanks.
