From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,2/2] hv_netvsc: Exclude non-TCP port numbers
 from vRSS hashing
Date: Mon, 17 Apr 2017 11:05:43 -0400 (EDT)
Message-ID: <20170417.110543.604318496583172160.davem@davemloft.net>
References: <1492022106-4070-1-git-send-email-haiyangz@exchange.microsoft.com>
        <1492022106-4070-2-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492022106-4070-2-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Wed, 12 Apr 2017 11:35:06 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Azure hosts are not supporting non-TCP port numbers in vRSS hashing for
> now. For example, UDP packet loss rate will be high if port numbers are
> also included in vRSS hash.
> 
> So, we created this patch to use only IP numbers for hashing in non-TCP
> traffic.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
