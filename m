From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: smc_close: mark expected switch fall-throughs
Date: Sat, 21 Oct 2017 20:21:00 -0500
Message-ID: <20171021202100.Horde.z-7P99HVhWm0m3hXj5cOjur@gator4166.hostgator.com>
References: <20171019220244.GA22041@embeddedor.com>
 <20171022.020835.2065879880300400886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: ubraun@linux.vnet.ibm.com, linux-s390@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway31.websitewelcome.com ([192.185.143.38]:25050 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932271AbdJVBVC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:21:02 -0400
Received: from cm10.websitewelcome.com (cm10.websitewelcome.com [100.42.49.4])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 519E0DD83C
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 20:21:01 -0500 (CDT)
In-Reply-To: <20171022.020835.2065879880300400886.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting David Miller <davem@davemloft.net>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 19 Oct 2017 17:02:44 -0500
>
>> @@ -360,7 +360,8 @@ static void smc_close_passive_work(struct  
>> work_struct *work)
>>  	case SMC_PEERCLOSEWAIT1:
>>  		if (rxflags->peer_done_writing)
>>  			sk->sk_state = SMC_PEERCLOSEWAIT2;
>> -		/* fall through to check for closing */
>> +		/* to check for closing */
>> +		/* fall through */
>
> Gustavo please look at what you are doing to the code.
>
> This was a nice easy to read sentence in the comment, and now
> you've chopped it up into two pieces and made it awkward and
> more difficult to read.

You're right.

What about this instead:

/* fall through */
/* to check for closing */
