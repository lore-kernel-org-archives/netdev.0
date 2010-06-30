From: David Miller <davem@davemloft.net>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 14:22:56 -0700 (PDT)
Message-ID: <20100630.142256.77345240.davem@davemloft.net>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
	<1277931829.4878.9.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: novickivan@gmail.com, netdev@vger.kernel.org,
	jmatthews@greenplum.com, theath@greenplum.com,
	herbert@gondor.apana.org.au
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757226Ab0F3VWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:22:43 -0400
In-Reply-To: <1277931829.4878.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 22:03:49 +0100

> In that packet capture I see TCP payload lengths which are 2, 3 and 4
> times the usual MSS of 1448 bytes, which implies that GRO or LRO is in
> use.  In RHEL 5.4 the TCP stack does not ACK often enough in this case
> because it is missing this change:
> 
> commit ff9b5e0f08cb650d113eef0c654f931c0a7ae730
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Aug 31 15:11:02 2006 -0700
> 
>     [TCP]: Fix rcv mss estimate for LRO

It certainly could be, I'll try make sure this gets rectified,
thanks!
