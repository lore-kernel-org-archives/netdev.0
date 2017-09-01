From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next, 0/4] cleanups and fixes of channel settings
Date: Fri, 1 Sep 2017 14:36:26 -0700
Message-ID: <20170901143626.66f08395@xeon-e3>
References: <20170901213007.10325-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, davem@davemloft.net,
        netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901213007.10325-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  1 Sep 2017 14:30:03 -0700
Haiyang Zhang <haiyangz@exchange.microsoft.com> wrote:

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> This patch set cleans up some unused variables, unnecessary checks.
> Also fixed some limit checking of channel number.
> 
> 
> Haiyang Zhang (4):
>   hv_netvsc: Clean up an unused parameter in rndis_filter_set_rss_param()
>   hv_netvsc: Simplify num_chn checking in rndis_filter_device_add()
>   hv_netvsc: Simplify the limit check in netvsc_set_channels()
>   hv_netvsc: Fix the channel limit in netvsc_set_rxfh()
> 
>  drivers/net/hyperv/hyperv_net.h   |  2 +-
>  drivers/net/hyperv/netvsc_drv.c   |  7 ++-----
>  drivers/net/hyperv/rndis_filter.c | 11 +++++------
>  3 files changed, 8 insertions(+), 12 deletions(-)
> 

Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
