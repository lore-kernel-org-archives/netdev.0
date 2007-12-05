From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 1/4] netns: Tag the network flow with the network namespace
 it is in (v2)
Date: Wed, 05 Dec 2007 09:49:54 +0300
Message-ID: <47564A12.3040502@sw.ru>
References: <E1IzgRN-0006Hq-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, den@openvz.org,
	davem@davemloft.net, devel@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:54923 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751081AbXLEGs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 01:48:58 -0500
In-Reply-To: <E1IzgRN-0006Hq-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Denis V. Lunev <den@sw.ru> wrote:
>> could you exactly point me out the flow cache your are talking about.
>> Is this dst entry cache or struct flow_cache described in the
>> net/core/flow.c
> 
> The flow object is embedded in struct rtable so does its size change?
> 
> Cheers,

SLAB allocator, x86_64 host

Before the patch:
ip6_dst_cache        384   10
xfrm_dst_cache       384   10
ip_dst_cache         384   10

After the patch:
ip6_dst_cache        384   10
xfrm_dst_cache       384   10
ip_dst_cache         384   10

Regards,
	Den
