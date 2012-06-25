From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Mon, 25 Jun 2012 15:43:40 -0700 (PDT)
Message-ID: <20120625.154340.158890441165257041.davem@davemloft.net>
References: <1338615992.2760.1665.camel@edumazet-glaptop>
	<CAGK4HS8Hae_4sNQeGXGc4ocK1-2DVtCUdBAPj7+DY_iF6-2zOA@mail.gmail.com>
	<1340440962.17495.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, dave.taht@gmail.com,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632Ab2FYWno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 18:43:44 -0400
In-Reply-To: <1340440962.17495.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Jun 2012 10:42:42 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> On Sat, 2012-06-23 at 00:34 -0700, Vijay Subramanian wrote:
> 
>> This  patch ([PATCH net-next] tcp: avoid tx starvation by SYNACK
>> packets)  is neither in net/net-next trees nor on patchwork. Maybe it
>> was missed since it was sent during the merge window. Is this not
>> needed anymore or is it being tested currently?
> 
> You're right, thanks for the reminder !
> 
> [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets

I don't agree with this change.

What is the point in having real classification configuration if
arbitrary places in the network stack are going to override SKB
priority with a fixed priority setting?

I bet the person who set listening socket priority really meant it and
does not expect you to override it.
