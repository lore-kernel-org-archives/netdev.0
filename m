From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Mon, 31 Mar 2008 19:04:54 +0800
Message-ID: <47F0C556.8090109@cn.fujitsu.com>
References: <47F0AA16.1070900@cn.fujitsu.com>	<20080331.181551.118587102.yoshfuji@linux-ipv6.org>	<47F0C101.9090302@cn.fujitsu.com> <20080331.195323.83430743.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63283 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbYCaLFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 07:05:36 -0400
In-Reply-To: <20080331.195323.83430743.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 said the following on 2008-3-31 18:53:
>>>> Check length of setsockopt's optval, which provided by user, before copy it
>>>> from user space.
>>> Please use "<" not "==".
>>>
>> There are two reasons that why I only check whether
>> len of optval is equal to that one in user space.
>> 1. We currently copy the entire structure from user
>>    to kernel.
>> 2. In other cases, such as IPV6_LEAVE/JOIN_ANYCAST,
>>    we check whether the len is equal to struct's len.
>>
>> So, Yoshifuji-san, can you tell me more about why we
>> should use "<"? :)
> 
> POSIX, as we have some comments in that file ;-).
> If it is shorter than expected, -EINVAL, otherwise, no error.
> We need to fix other sites as well.
> 

ooh, I see.
I will take a business trip to Japan tomorrow and I will finish
this patch since I come back weekend.
Thank you for your explanation.

--WCN

