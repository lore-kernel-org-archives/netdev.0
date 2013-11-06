From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] IPsec improvements
Date: Tue, 05 Nov 2013 23:48:31 -0500 (EST)
Message-ID: <20131105.234831.2190193542602272571.davem@davemloft.net>
References: <cover.1381923854.git.mathias.krause@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org
To: mathias.krause@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936Ab3KFEsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 23:48:36 -0500
In-Reply-To: <cover.1381923854.git.mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <mathias.krause@secunet.com>
Date: Tue,  5 Nov 2013 14:54:08 +0100

> This series moves pskb_put() to the core code -- making the code
> duplication in caif obsolete (patches 1 and 2).
> 
> Additionally does this series optimize the IPsec receive path in patch 3
> by allowing skb_cow_data() to leave the buffer fragmented. I noticed the
> linearization to be a bottleneck when doing some VPN gateway benchmarks.
> Linearization of the buffer isn't needed in the receive path as the
> crypto API (and all other users of skb_cow_data) can handle sg.
> 
> With patch 3 applied I was able to increase the throughput of an IPsec
> gateway from 7.12 Gbit/s to 7.28 Gbit/s.

Please deal with the feedback given to you by Ben about referring to
variables with the '@' prefix consistently in comments, then resend
this entire patch series.

Thanks.
