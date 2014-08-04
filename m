From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: octeon_mgmt: Use devm_ioremap_resource
Date: Mon, 04 Aug 2014 12:38:53 -0700 (PDT)
Message-ID: <20140804.123853.791933051871769418.davem@davemloft.net>
References: <20140731070653.GA3759@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luka@openwrt.org, rmk+kernel@arm.linux.org.uk,
	david.daney@cavium.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140731070653.GA3759@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Thu, 31 Jul 2014 12:36:53 +0530

> This patch introduces the use of devm_ioremap_resource instead of
> devm_request_mem_region and devm_ioremap. The error handling on the
> platform_get_resource is done way with. The size and start fields in the
> octeon_mgmt are no longer needed. So they are removed and there
> initialization skipped. Also, error handling is added on the values
> returned by devm_ioremap_resource.
> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
> Not compile tested.

David Daney provided you with a mechanism by which you could
compile test this change, and then I see no response at all
from you after that.

I'm not applying this until it is at least compile tested.
