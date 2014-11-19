From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: delete protocol and unregister rtnetlink when
 cleanup
Date: Wed, 19 Nov 2014 16:55:44 -0500 (EST)
Message-ID: <20141119.165544.2020739689487881127.davem@davemloft.net>
References: <546B20F8.6010806@cn.fujitsu.com>
	<CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
	<546BF3EB.1080603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684AbaKSVzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 16:55:47 -0500
In-Reply-To: <546BF3EB.1080603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 19 Nov 2014 09:35:39 +0800

> pim6_protocol was added when initiation, but it not deleted.
> Similarly, unregister RTNL_FAMILY_IP6MR rtnetlink.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> v2: add missing rtnl_unregister()

Applied, thanks.
