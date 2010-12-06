From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 06 Dec 2010 20:30:08 +0000
Message-ID: <1291667408.3443.10.camel@bwh-desktop>
References: <20101206121829.5b8c852e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17985 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467Ab0LFUaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 15:30:11 -0500
In-Reply-To: <20101206121829.5b8c852e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-06 at 12:18 -0800, Stephen Hemminger wrote:
> I inspected all drivers in net-next to see which drivers are using
> LRO and which ones are broken. Most concerning is that Chelsio
> and Solarflare drivers ignore ETH_FLAG_LRO.
> 
> The ones that are using LRO but allow disabling it:
>   qlcnic, netxen, mv643, s2io, myi10ge, bnx2x, ixgbe, vmxnet3
> 
> One driver seems confused about LRO vs GRO:
>   mlx4 - comments about LRO and depends on LRO but driver is using GRO

sfc is also in this category.  (And it's not confused, it was using
inet_lro before being converted to GRO.)

> Drivers with not using ethtool interface to disable LRO:
>   pasemi_mac, sfc, ehea, cxgb3, cxgb4

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

