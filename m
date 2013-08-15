From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ethernet/via/via-velocity.c: update napi
 implementation
Date: Thu, 15 Aug 2013 01:39:07 -0700 (PDT)
Message-ID: <20130815.013907.319502653692029822.davem@davemloft.net>
References: <1376490413-12067-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, roszenrami@gmail.com, dshwatrz@gmail.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, grant.likely@linaro.org,
	rob.herring@calxeda.com
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376490413-12067-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 14 Aug 2013 16:26:53 +0200

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Drivers supporting NAPI should use a NAPI-specific function for receiving
> packets.  Hence netif_rx is changed to netif_receive_skb.
> 
> Furthermore netif_napi_del should be used in the probe and remove function
> to clean up the NAPI resource information.
> 
> Thanks to Francois Romieu, David Shwatrz and Rami Rosen for their help on
> this patch.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks.
