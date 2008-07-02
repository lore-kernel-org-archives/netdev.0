From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 1/7] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Wed, 02 Jul 2008 14:53:29 +0200
Message-ID: <486B7A49.7090103@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A2D5.1010605@cn.fujitsu.com> <4869FA91.30405@trash.net> <486B3868.8060206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36601 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbYGBMxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 08:53:30 -0400
In-Reply-To: <486B3868.8060206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> v2->v3:
>   Do unwinding when error happens.
> 
> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> In af_packet, we check all positive increment for promiscuity and allmulti
> to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Acked-by: Patrick McHardy <kaber@trash.net>

