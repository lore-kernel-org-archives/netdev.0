From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers/net/ethernet/via/via-velocity.c: update napi
 implementation
Date: Thu, 15 Aug 2013 01:42:08 +0400
Message-ID: <520BF9B0.80104@cogentembedded.com>
References: <1376490413-12067-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, roszenrami@gmail.com,
	dshwatrz@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	grant.likely@linaro.org, rob.herring@calxeda.com
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376490413-12067-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/14/2013 06:26 PM, Julia Lawall wrote:

> From: Julia Lawall <Julia.Lawall@lip6.fr>

> Drivers supporting NAPI should use a NAPI-specific function for receiving
> packets.  Hence netif_rx is changed to netif_receive_skb.

> Furthermore netif_napi_del should be used in the probe and remove function
> to clean up the NAPI resource information.

> Thanks to Francois Romieu, David Shwatrz and Rami Rosen for their help on
> this patch.

> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

> ---
> I still don't understand the reason for choosing netif_receive_skb,
> specifically.  This patch is not tested.

    This driver is not the only one with the netif_rx() used with NAPI issue. 
I also overlooked this when converting drivers/net/ethernet/renesas/sh_eth.c 
to NAPI. I'll try to change the call and see if netperf would behave better...

WBR, Sergei
