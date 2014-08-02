From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851-ml: Use devm_ioremap_resource
Date: Sat, 02 Aug 2014 16:41:10 -0700 (PDT)
Message-ID: <20140802.164110.991385652436936022.davem@davemloft.net>
References: <20140801152913.GA11494@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jg1.han@samsung.com, michael.opdenacker@free-electrons.com,
	arend@broadcom.com, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801152913.GA11494@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 1 Aug 2014 20:59:13 +0530

> This patch introduces the use of devm_ioremap_resource, devm_kmalloc and
> does away with the functions to free the allocated memory in the probe
> and remove functions. Also, some labels are done away with. A bug is
> fixed as two regions are allocated in the probe function, but only one
> is freed in the remove function.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied.
