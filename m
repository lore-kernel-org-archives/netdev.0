From: David Miller <davem@davemloft.net>
Subject: Re: flow director and packet ordering
Date: Sun, 05 Jul 2009 15:53:54 -0700 (PDT)
Message-ID: <20090705.155354.85683961.davem@davemloft.net>
References: <20090616.023132.194401812.davem@davemloft.net>
	<20090705041955.GA7892@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755837AbZGEWxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 18:53:48 -0400
In-Reply-To: <20090705041955.GA7892@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 5 Jul 2009 12:19:55 +0800

> David Miller <davem@davemloft.net> wrote:
>>
>> In the meantime you cannot switch the RX queue mapping without
>> introducing reordering.
>> 
>> So my original fears and doubts still stand :-)
> 
> Methinks this whole idea is doomed.  The fact is as long as there
> are more sockets than queues, then you can have two sockets pull
> the same queue in different directions and there's nothing you can
> do about that.
> 
> That's my bit of uncertainty for you :)

Flows map to queues, queues don't move.  Rather the mapping between
flows and queues changes dynamically.
