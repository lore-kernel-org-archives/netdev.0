From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/3 2.6.27] cxgb3 - Add page support to jumbo frame Rx
 queue
Date: Wed, 21 May 2008 18:55:30 -0700
Message-ID: <4834D292.5020907@chelsio.com>
References: <20080521015737.6218.32204.stgit@speedy5> <20080521172024.a1044aea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15610 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733AbYEVBzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 21:55:46 -0400
In-Reply-To: <20080521172024.a1044aea.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 20 May 2008 18:57:37 -0700
> Divy Le Ray <divy@chelsio.com> wrote:
>
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Add page support to Jumbo frame Rx queues.
>>
>> ...
>>
>> @@ -460,7 +464,8 @@ nomem:				q->alloc_failed++;
>>  			if (q->use_pages) {
>>  				if (q->pg_chunk.page) {
>>  					put_page(q->pg_chunk.page);
>> -					__free_page(q->pg_chunk.page);
>> +					__free_pages(q->pg_chunk.page,
>> +						     q->order);
>>  					q->pg_chunk.page =
>>  						sd->pg_chunk.page = NULL;
>>  				}
>>     
>
> This hunk doesn't apply to 2.6.26-rc3, afacit.  The code it's patching
> just isn't there.  But I think I fixed it up OK.
>   

My bad.
I modified the first patch just before submission - namely to avoid 
freeing the Rx page if the DMA mapping failed.
I managed to submit without locally pushing the follwing patches first. 
Sorry about that.
I'm resubmitting the series.

Cheers,
Divy

