From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 duplicate address detection erroneously marking address
 as duplicate when a host receives its own multicast packets?
Date: Wed, 21 Apr 2010 22:30:22 -0700 (PDT)
Message-ID: <20100421.223022.126085425.davem@davemloft.net>
References: <4BCFA615.8060205@hp.com>
	<20100422024140.GA7215@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, sam.cannell@catalyst.net.nz,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60583
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993Ab0DVFaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:30:17 -0400
In-Reply-To: <20100422024140.GA7215@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Apr 2010 10:41:40 +0800

> Brian Haley <brian.haley@hp.com> wrote:
>> 
>> Well, my initial reaction is XVM is doing the wrong thing looping-back
>> multicast packets.  You can try the following (untested) patch, I can
>> only confirm it compiles.
> 
> I agree, whatever is looping the packet back should be fixed.

Ethernet does not send multicasts to itself, so we're definitely not
going to cater to this XVM behavior.
