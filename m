From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix possible socket refcount problem for ipv6
Date: Wed, 05 Sep 2012 17:16:56 -0400 (EDT)
Message-ID: <20120905.171656.2265953007101513278.davem@davemloft.net>
References: <1346878398-4782-1-git-send-email-ja@ssi.bg>
	<1346878620.13121.161.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759440Ab2IEVQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:16:59 -0400
In-Reply-To: <1346878620.13121.161.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Sep 2012 22:57:00 +0200

> On Wed, 2012-09-05 at 23:53 +0300, Julian Anastasov wrote:
>> 	commit 144d56e91044181ec0ef67aeca91e9a8b5718348
>> ("tcp: fix possible socket refcount problem") is missing
>> the IPv6 part. As tcp_release_cb is shared by both protocols
>> we should hold sock reference for the TCP_MTU_REDUCED_DEFERRED
>> bit.
>> 
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
