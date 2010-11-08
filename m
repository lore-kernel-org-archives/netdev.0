From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix overlap check for fragments
Date: Mon, 08 Nov 2010 12:19:02 -0800 (PST)
Message-ID: <20101108.121902.189697974.davem@davemloft.net>
References: <4CD3F0F2.2080804@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org, kaber@trash.net
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43048
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754160Ab0KHUSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:18:38 -0500
In-Reply-To: <4CD3F0F2.2080804@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 05 Nov 2010 19:56:34 +0800

> The type of FRAG6_CB(prev)->offset is int, skb->len is *unsigned* int,
> and offset is int.
> 
> Without this patch, type conversion occurred to this expression, when
> (FRAG6_CB(prev)->offset + prev->len) is less than offset.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
