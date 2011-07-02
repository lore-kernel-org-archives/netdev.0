From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv4: Don't use ufo handling on later transformed
 packets
Date: Fri, 01 Jul 2011 17:34:39 -0700 (PDT)
Message-ID: <20110701.173439.253029974012720350.davem@davemloft.net>
References: <20110630091820.GB13201@secunet.com>
	<20110630091932.GC13201@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab1GBAez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:34:55 -0400
In-Reply-To: <20110630091932.GC13201@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 30 Jun 2011 11:19:32 +0200

> We might call ip_ufo_append_data() for packets that will be IPsec
> transformed later. This function should be used just for real
> udp packets. So we check for rt->dst.header_len which is only
> nonzero on IPsec handling and call ip_ufo_append_data() just
> if rt->dst.header_len is zero.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
