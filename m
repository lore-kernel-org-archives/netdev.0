From: David Miller <davem@davemloft.net>
Subject: Re: Namespaces and inetpeer
Date: Mon, 12 Mar 2012 02:35:05 -0700 (PDT)
Message-ID: <20120312.023505.2024370184180125281.davem@davemloft.net>
References: <20120310132529.GA3631@gondor.apana.org.au>
	<20120312085756.GL15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954Ab2CLJff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 05:35:35 -0400
In-Reply-To: <20120312085756.GL15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 12 Mar 2012 09:57:56 +0100

> On Sun, Mar 11, 2012 at 12:25:29AM +1100, Herbert Xu wrote:
>> Hi:
>> 
>> While looking through the inetpeer code I noticed that there is
>> no namespace support at all.  This means that metric and other
>> information will be leaking across namespaces.  As IP addresses
>> are meant to be independent between them, this is not a good thing.
>> 
> 
> Actually, it would be nice if we could have an inetpeer base per
> fib table. This would imply namespace awareness and it would
> handle the problem when we have mulitiple routes (with different
> metrics etc.) to the same ip address on policy routing.

Then you will ask for one per security policy too, to handle IPSEC.
