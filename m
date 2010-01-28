From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: IPsec rules are ineffective with ipv6
Date: Thu, 28 Jan 2010 05:51:48 -0800 (PST)
Message-ID: <20100128.055148.127214200.davem@davemloft.net>
References: <4B6049EB.8030803@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	linux-sctp@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932208Ab0A1Nvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:51:36 -0500
In-Reply-To: <4B6049EB.8030803@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Wed, 27 Jan 2010 15:12:59 +0100

> xfrm_lookup() is missing in sctp_v6_xmit(), add it.
> 
> Signed-off-by: Junwei Zhang <junwei.zhang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Doing this every transmit packet is overkill.

Whatever calculates the route that ends up in skb_dst(skb)
should be making this xfrm_lookup() call, not here.
