From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Tue, 15 Jan 2013 16:02:32 +0200
Message-ID: <50F56178.8000502@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
 <1358176310-31504-10-git-send-email-yuvalmin@broadcom.com>
 <1358184123.8744.3127.camel@edumazet-glaptop>
 <1358189075.8744.3320.camel@edumazet-glaptop>
 <50F50537.3030608@broadcom.com>
 <1358260752.8744.5677.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: "Eric Dumazet" <eric.dumazet@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3005 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086Ab3AOPCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 10:02:17 -0500
In-Reply-To: <1358260752.8744.5677.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> bnx2x not setting gso_segs means that qdisc accounting on ingress is
>>> completely wrong.
>>
>> Notice this behaviour was not introduced in this patch -
>>
>>	...
>>
>> We could either:
>>   1. Continue with this patch, later sending a patch correcting gso_segs,
>>      as this is not a new issue.
>>   2. Send a V2 patch-series which will also set gso_segs correctly.
> 
> I am fine with any solution, as long as we fix the problem.

Eric - Thanks.
Just to be certain - gso_segs should hold the number of non-aggregated packets
contained in the skb's frags, right?


Dave -

Considering Eric's response, following with option (1) or (2) seems like the
right way to go.

Do you want a new patch series which will include a fix for this,
or will you accept a later fix that sets the gso_segs correctly?

(considering this issue is not introduced in this patch,
merely isn't being solved by it)

Thanks,
Yuval Mintz
