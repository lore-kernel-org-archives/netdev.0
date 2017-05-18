From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net1080: Remove unused function nc_dump_ttl()
Date: Thu, 18 May 2017 14:46:53 -0400 (EDT)
Message-ID: <20170518.144653.575560734197670862.davem@davemloft.net>
References: <20170518175719.103143-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mka@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170518175719.103143-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <mka@chromium.org>
Date: Thu, 18 May 2017 10:57:19 -0700

> The function is not used, removing it fixes the following warning when
> building with clang:
> 
> drivers/net/usb/net1080.c:271:20: error: unused function
>     'nc_dump_ttl' [-Werror,-Wunused-function]
> 
> Also remove the definition of TTL_THIS, which is only used in
> nc_dump_ttl()
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Applied to net-next.
