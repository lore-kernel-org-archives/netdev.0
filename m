From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 15:25:24 +0300
Message-ID: <49D60034.1010508@redhat.com>
References: <49D49C1F.6030306@novell.com> <200904022243.21088.rusty@rustcorp.com.au> <49D4B4A3.5070008@novell.com> <49D4B87D.2000202@redhat.com> <20090402145018.GA816@gondor.apana.org.au> <49D4D301.2090209@redhat.com> <20090402154041.GA1774@gondor.apana.org.au> <49D4E072.2060003@redhat.com> <20090402160941.GB2173@gondor.apana.org.au> <49D4EDBD.3050900@redhat.com> <20090402170610.GA3001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	Rusty Russell <rusty@rustcorp.com.au>, anthony@codemonkey.ws,
	andi@firstfloor.org, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55323 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430AbZDCMZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2009 08:25:12 -0400
In-Reply-To: <20090402170610.GA3001@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 07:54:21PM +0300, Avi Kivity wrote:
>   
>> 3ms latency for ping?
>>
>> (ping will always be scheduled immediately when the reply arrives if I  
>> understand cfs, so guest load won't delay it)
>>     
>
> That only happens if the guest immediately does some CPU-intensive
> computation 3ms and assuming its timeslice lasts that long.
>   

 Note that this happens even if the computation is SCHED_BATCH.

> In any case, the same thing will happen right now if the host or
> some other guest on the same CPU hogs the CPU for 3ms.
>
>   

If the host is overloaded, that's fair.  But millisecond latencies 
without host contention is not a good result.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

