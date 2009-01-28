From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4]: Revamp TX hashing.
Date: Wed, 28 Jan 2009 12:41:26 -0800 (PST)
Message-ID: <20090128.124126.119524270.davem@davemloft.net>
References: <20090127.164024.141230513.davem@davemloft.net>
	<20090128090203.GA15674@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37113
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757439AbZA1Ul3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:41:29 -0500
In-Reply-To: <20090128090203.GA15674@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jan 2009 20:02:03 +1100

> One thing that I've been thinking about is that it would be
> really useful if we guaranteed that every inbound packet carried
> a hash with it.  This could be used to help subsequent processing
> such as routing, netfilter, etc. since they all need to make
> decisions based on flows.

Ok, all the complicated cases will have to occur in decapsulators :-)

For example, IP tunnels would need to compute the hash as would most
forms of IPSEC since often we can't even see the inner flow until
after decryption even for transport cases.
