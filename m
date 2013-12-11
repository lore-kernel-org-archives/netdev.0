From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 6/6] net_sched: make macro be enclosed in parenthesis
Date: Wed, 11 Dec 2013 10:16:35 +0800
Message-ID: <52A7CB03.2000209@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com> <1386680134-85452-7-git-send-email-yangyingliang@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7477@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20405 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab3LKCQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:16:54 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7477@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/10 21:01, David Laight wrote:
>>  #define SKIP_NONLOCAL(skb)			\
>> +({						\
>>  	if (unlikely(skb->sk == NULL)) {	\
>>  		*err = -1;			\
>>  		return;				\
>> -	}
>> +	}					\
>> +})
> 
> That one should be lined up against the fence and shot :-)
> 
> 

Hmm, not fully understand, did you mean that:

#define SKIP_NONLOCAL(skb) ({			\
 	if (unlikely(skb->sk == NULL)) {	\
 		*err = -1;			\
		return;				\
	}					\
})
