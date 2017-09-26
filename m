From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix the real number of queues of
 non-vRSS cases
Date: Mon, 25 Sep 2017 20:21:27 -0700 (PDT)
Message-ID: <20170925.202127.705641100210802806.davem@davemloft.net>
References: <20170922223138.28348-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922223138.28348-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri, 22 Sep 2017 15:31:38 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> For older hosts without multi-channel (vRSS) support, and some error
> cases, we still need to set the real number of queues to one.
> This patch adds this missing setting.
> 
> Fixes: 8195b1396ec8 ("hv_netvsc: fix deadlock on hotplug")
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
