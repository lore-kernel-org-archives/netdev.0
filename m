From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: Change skb->data before using icmpv6_notify()
 to propagate redirect
Date: Fri, 14 Dec 2012 13:16:38 -0500 (EST)
Message-ID: <20121214.131638.1339938938384537260.davem@davemloft.net>
References: <50CB22CF.9010505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756936Ab2LNSQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 13:16:39 -0500
In-Reply-To: <50CB22CF.9010505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Fri, 14 Dec 2012 20:59:59 +0800

> 
> In function ndisc_redirect_rcv(), the skb->data points to the transport
> header, but function icmpv6_notify() need the skb->data points to the
> inner IP packet. So before using icmpv6_notify() to propagate redirect,
> change skb->data to point the inner IP packet that triggered the sending
> of the Redirect, and introduce struct rd_msg to make it easy.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>

Applied and queued up for -stable.
