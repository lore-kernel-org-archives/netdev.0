From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Wed, 16 Dec 2009 21:02:50 -0800
Message-ID: <4B29BB7A.8000307@us.ibm.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com> <20091217031233.GA26027@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:59167 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbZLQFDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 00:03:10 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBH4wAB9025403
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 21:58:10 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBH52um6163130
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 22:02:57 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBH52thZ001895
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 22:02:56 -0700
In-Reply-To: <20091217031233.GA26027@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Dec 16, 2009 at 05:43:00PM -0800, Sridhar Samudrala wrote:
>   
>> I had to change virtnet_xmit_poll() to get it working. See below.
>> With this change, i don't see any 'queue full' warnings, but requeues
>> are still happening at the qdisc level (sch_direct_xmit() finds that
>> tx queue is stopped and does requeues).
>>     
>
> More importantly how does the performance look?
>   
TCP stream throughput is around the same 3200Mb/sec

Thanks
Sridhar

