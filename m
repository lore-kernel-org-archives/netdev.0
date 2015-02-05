From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm6: Fix a offset value for network header
 in _decode_session6
Date: Thu, 05 Feb 2015 15:38:54 -0800 (PST)
Message-ID: <20150205.153854.2003362622735317610.davem@davemloft.net>
References: <m2d25phhox.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
To: tazaki@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbbBEXiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:38:54 -0500
In-Reply-To: <m2d25phhox.wl@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Date: Wed, 04 Feb 2015 23:31:10 +0900

> When a network-layer header has multiple IPv6 extension headers, then offset
> for mobility header goes wrong. This regression breaks an xfrm policy lookup
> for a particular receive packet. Binding update packets of Mobile IPv6
> are all discarded without this fix.
> 
> Fixes: de3b7a06dfe1 ("xfrm6: Fix transport header offset in _decode_session6.")
> Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>

Steffen, please review and/or integrate into your tree.

Thanks.
