From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ah: reload pointers to skb data after calling
 skb_cow_data()
Date: Tue, 11 Jan 2011 14:04:52 -0800 (PST)
Message-ID: <20110111.140452.45136484.davem@davemloft.net>
References: <4D2C8FBD.8060701@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751795Ab1AKWEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 17:04:20 -0500
In-Reply-To: <4D2C8FBD.8060701@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 11 Jan 2011 18:13:33 +0100

>>From ba44ef6e00ca0f4c13e425f4a39e8749c56db843 Mon Sep 17 00:00:00 2001
> From: Dang Hongwu <hongwu.dang@6wind.com>
> Date: Tue, 11 Jan 2011 12:00:05 -0500
> Subject: [PATCH] ah: reload pointers to skb data after calling skb_cow_data()
> 
> skb_cow_data() may allocate a new data buffer, so pointers on
> skb should be set after this function.
> 
> Bug was introduced by commit dff3bb06 and 8631e9bd.
> 
> Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
> Acked-by: Krzysztof Witek <krzysztof.witek@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
