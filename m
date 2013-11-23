From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] gro: Only verify TCP checksums for candidates
Date: Sat, 23 Nov 2013 14:47:14 -0800 (PST)
Message-ID: <20131123.144714.582960796340864160.davem@davemloft.net>
References: <20131122023013.GA6387@gondor.apana.org.au>
	<20131122023129.GA6506@gondor.apana.org.au>
	<1385099712.10637.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, alexander.h.duyck@intel.com,
	alexander.duyck@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756314Ab3KWWio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:38:44 -0500
In-Reply-To: <1385099712.10637.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Nov 2013 21:55:12 -0800

> On Fri, 2013-11-22 at 10:31 +0800, Herbert Xu wrote:
>> In some cases we may receive IP packets that are longer than
>> their stated lengths.  Such packets are never merged in GRO.
>> However, we may end up computing their checksums incorrectly
>> and end up allowing packets with a bogus checksum enter our
>> stack with the checksum status set as verified.
>> 
>> Since such packets are rare and not performance-critical, this
>> patch simply skips the checksum verification for them.
>> 
>> Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Appplied.
