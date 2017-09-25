From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] hv_netvsc: Fix the real number of queues of
 non-vRSS cases
Date: Mon, 25 Sep 2017 03:38:19 -0700
Message-ID: <20170925033819.03bad587@shemminger-XPS-13-9360>
References: <20170922223138.28348-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, davem@davemloft.net,
        netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922223138.28348-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2017 15:31:38 -0700
Haiyang Zhang <haiyangz@exchange.microsoft.com> wrote:

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> For older hosts without multi-channel (vRSS) support, and some error
> cases, we still need to set the real number of queues to one.
> This patch adds this missing setting.
> 
> Fixes: 8195b1396ec8 ("hv_netvsc: fix deadlock on hotplug")
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Yes, this should fix issues with WS2012.

Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
