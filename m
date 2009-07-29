From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 18:34:51 -0700 (PDT)
Message-ID: <20090728.183451.93398827.davem@davemloft.net>
References: <20090729004428.GA765@gondor.apana.org.au>
	<20090728.180647.241258705.davem@davemloft.net>
	<20090729012523.GA1583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755328AbZG2Beo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 21:34:44 -0400
In-Reply-To: <20090729012523.GA1583@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Jul 2009 09:25:23 +0800

> On Tue, Jul 28, 2009 at 06:06:47PM -0700, David Miller wrote:
>>
>> More interesting to me is the case where the queue is not
>> filled up, or is very nearly so. :-)
> 
> Do you mean the hardware queue? In that case perhaps Krishna's
> proposal of bypassing the qdisc would be the best.

Wouldn't that bypass any rate limiting enforcement done by
the qdisc too?
