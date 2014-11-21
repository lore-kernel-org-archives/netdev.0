From: Chris Mason <clm@fb.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 11:47:06 -0500
Message-ID: <1416588426.24312.6@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	<1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416587848.8629.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49547 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758422AbaKUQrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:47:12 -0500
In-Reply-To: <1416587848.8629.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Nov 21, 2014 at 11:37 AM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> On Fri, 2014-11-21 at 08:31 -0800, Eric Dumazet wrote:
> 
>>  Can you double check, or send whole __kfree_skb() disassembly ?
>> 
>>  I do not understand how skb->fclone could possibly trap _at_ this 
>> point.
> 
> Oh well, I think commit ce1a4ea3f1258 ("net: avoid one atomic 
> operation
> in skb_clone()") is the problem, I'll send a revert.

Once my current run is done, I can revert this and try a loop.  But I 
don't see how this commit causes a use-after-free on the skb itself?

-chris
