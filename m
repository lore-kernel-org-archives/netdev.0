From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Mon, 21 May 2007 17:56:02 +1000
Message-ID: <E1Hq2kM-0000ID-00@gondolin.me.apana.org.au>
References: <20070515.143207.80029051.davem@davemloft.net>
Cc: xma@us.ibm.com, rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1276 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754657AbXEUH4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 03:56:47 -0400
In-Reply-To: <20070515.143207.80029051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Shirley Ma <xma@us.ibm.com>
> Date: Tue, 15 May 2007 14:22:57 -0700
> 
>>       I just wonder without TSO support in HW, how much benefit we
>> can get by pushing GSO from interface layer to device layer besides
>> we can do multiple packets in IPoIB.
> 
> I bet the gain is non-trivial.

Yep, for any NIC that supports SG but not TSO then software GSO will
be a big win.  When the NIC doesn't support SG then the win is mostly
offset by the need to copy the packet again.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
