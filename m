From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: Re: [Patch] net/xfrm/xfrm_policy.c: Some small improvements
Date: Thu, 06 Dec 2007 15:37:46 +0100
Message-ID: <4758093A.7010608@student.ltu.se>
References: <20071206110123.GB2469@hacking> <20071206.031434.179419183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, akpm@osdl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:43239 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLFOfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:35:34 -0500
In-Reply-To: <20071206.031434.179419183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: WANG Cong <xiyou.wangcong@gmail.com>
> Date: Thu, 6 Dec 2007 19:01:23 +0800
>
>   
>> This patch contains the following changes.
>>
>> 	- Use 'bool' instead of 'int' for booleans.
>> 	- Use 'size_t' instead of 'int' for 'sizeof' return value.
>> 	- Some style fixes.
>>
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Cc: David Miller <davem@davemloft.net>
>> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
>>     
>
> Normally I would let a patch like this sit in my mailbox
> for a week and then delete it.
>   
That is evil! ;)
> But this time I'll just let you know up front that I
> don't see much value in this patch.  It is not a clear
> improvement to replace int's with bool's in my mind and
> the other changes are just whitespace changes.
>   
Is it not an improvement to distinct booleans from actual values? Do you 
use integers for ASCII characters too? It can also avoid some potential 
bugs like the 'if (i == TRUE)'...
What is wrong with 'size_t' (since it is unsigned, compared to (some) 
'int')?

/Richard Knutsson

