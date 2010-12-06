From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 06 Dec 2010 13:15:42 -0800
Message-ID: <4CFD527E.7000706@chelsio.com>
References: <20101206121829.5b8c852e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18365 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab0LFVPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:15:51 -0500
In-Reply-To: <20101206121829.5b8c852e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> I inspected all drivers in net-next to see which drivers are using
> LRO and which ones are broken. Most concerning is that Chelsio
> and Solarflare drivers ignore ETH_FLAG_LRO.
> 
> The ones that are using LRO but allow disabling it:
>   qlcnic, netxen, mv643, s2io, myi10ge, bnx2x, ixgbe, vmxnet3
> 
> One driver seems confused about LRO vs GRO:
>   mlx4 - comments about LRO and depends on LRO but driver is using GRO
> 
> Drivers with not using ethtool interface to disable LRO:
>   pasemi_mac, sfc, ehea, cxgb3, cxgb4

cxgb4 uses GRO, not LRO.
