From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] xfrm: use vmalloc_node() for percpu scratches
Date: Sat, 02 Nov 2013 01:21:56 -0400 (EDT)
Message-ID: <20131102.012156.131372678670615938.davem@davemloft.net>
References: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
	<1383292257-4634-2-git-send-email-steffen.klassert@secunet.com>
	<5273A67B.9070901@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab3KBFV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:21:57 -0400
In-Reply-To: <5273A67B.9070901@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 01 Nov 2013 17:02:51 +0400

>> @@ -220,8 +220,8 @@ static void ipcomp_free_scratches(void)
>>
>>   static void * __percpu *ipcomp_alloc_scratches(void)
>>   {
>> -	int i;
>>   	void * __percpu *scratches;
>> +	int i;
> 
>    This collateral change is not described in the changelog.

Yes, but I'm not going to block this series just for this.
