From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 12:07:55 +0800
Message-ID: <496D651B.2000106@cn.fujitsu.com>
References: <20090114034711.GA8361@gondor.apana.org.au> <496D61FE.7080500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52865 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbZANEHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 23:07:34 -0500
In-Reply-To: <496D61FE.7080500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> Herbert Xu wrote:
>   
>> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>     
>>> Actually the condition (optlen == 0) is included in (optlen < sizeof(struct in6_pktinfo)),
>>> so we do not need to check it separately.
>>>       
>> You don't need to check optval == NULL either since that's the
>> job of copy_from_user.
>>     
>
> If optval==NULL, what we should return?EINVAL or EFAULT?
> If it is EINVAL,then we should check it .otherwise it's the job of 
> copy_from_user
>   

I think if optval==NULL, the in6_pktinfo which is set should be remove. 
So, you should handle optval==NULL. Not just return error.

>   
>> Cheers,
>>     
>
>
>   

