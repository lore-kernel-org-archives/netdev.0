From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPV6]: Fix IPsec datagram fragmentation
Date: Fri, 15 Feb 2008 00:05:32 -0800
Message-ID: <OF3737A582.CBFC60B5-ON882573F0.002BE602-882573F0.002C7307@us.ibm.com>
References: <20080215062215.GA10735@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, kazunori@miyazawa.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:61000 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758887AbYBOIFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 03:05:42 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1F85VT0008041
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 03:05:31 -0500
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F85VCa166734
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 01:05:31 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.13.1/8.13.3) with ESMTP id m1F85UIJ020569
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 01:05:31 -0700
In-Reply-To: <20080215062215.GA10735@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the field name is kind of confusing here. It appears
that "local_df == 1" means "allow fragmentation" and
"local_df == 0" means "don't fragment". But "DF" to me
means "don't fragment", as in "IP_DF", so the field value
is backwards from what I'd expect. And maybe that's
what happened to in your patch, too, Herbert.

For the future, maybe we should rename that, or reverse
the sense of it (in v4 as well). :-)

                                        +-DLS

