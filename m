From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: use ISO C standard for array in linux/xfrm.h
Date: Wed, 17 Oct 2012 02:16:15 -0400 (EDT)
Message-ID: <20121017.021615.926368154563205088.davem@davemloft.net>
References: <1350402153-3889-1-git-send-email-nicolas.dichtel@6wind.com>
	<20121017054343.GA12671@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab2JQGQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 02:16:19 -0400
In-Reply-To: <20121017054343.GA12671@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 17 Oct 2012 07:43:43 +0200

> On Tue, Oct 16, 2012 at 05:42:33PM +0200, nicolas.dichtel@6wind.com wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> 
>> Use the ISO C standard compliant form instead of the gcc extension.
>> 
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  include/uapi/linux/xfrm.h | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
>> index 28e493b..6a6a605 100644
>> --- a/include/uapi/linux/xfrm.h
>> +++ b/include/uapi/linux/xfrm.h
>> @@ -30,7 +30,7 @@ struct xfrm_sec_ctx {
>>  	__u8	ctx_alg;
>>  	__u16	ctx_len;
>>  	__u32	ctx_sid;
>> -	char	ctx_str[0];
>> +	char	ctx_str[];
> 
> Hm, what's the benefit of such a change? The kernel source is full
> of these foo[0] type arrays. I don't see a reason to change this
> just for xfrm.

Agreed.
