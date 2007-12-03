From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.25 1/6][CORE] Remove unneeded ifdefs from sysctl_net_core.c
Date: Mon, 03 Dec 2007 11:57:53 +0300
Message-ID: <4753C511.6090105@openvz.org>
References: <47515A29.3070806@openvz.org> <m1tzn13l72.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57276 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbXLCI6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 03:58:10 -0500
In-Reply-To: <m1tzn13l72.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>> They include the whole file, but it is already compiled
>> out when SYSCTL=n, since it is obj-$(CONFIG_SYSCTL) target
>> in the Makefile.
> 
> Pavel thanks for sending these patches.  Might I ask
> for some level of acknowledgement when you rework one of
> my patches and send it off.

Sure. I though I've been doing exactly this thing. I've said
that unix ctls were from your tree and so on.

> I suppose this could be a case of duplicate thinking but
> this patch looks very familiar.

Hm... Do you mean that this one is from your tree? Sorry then,
I didn't know this. I can resend it with From: <you> if you wish.

> Eric

Thanks,
Pavel

>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>
>> ---
>>
>> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
>> index 113cc72..277c8fa 100644
>> --- a/net/core/sysctl_net_core.c
>> +++ b/net/core/sysctl_net_core.c
>> @@ -13,8 +13,6 @@
>>  #include <net/sock.h>
>>  #include <net/xfrm.h>
>>  
>> -#ifdef CONFIG_SYSCTL
>> -
>>  ctl_table core_table[] = {
>>  #ifdef CONFIG_NET
>>  	{
>> @@ -151,5 +149,3 @@ ctl_table core_table[] = {
>>  	},
>>  	{ .ctl_name = 0 }
>>  };
>> -
>> -#endif
>> -- 
>> 1.5.3.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

