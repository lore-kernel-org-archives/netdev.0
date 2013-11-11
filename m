From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Mon, 11 Nov 2013 16:12:07 +0100
Message-ID: <20131111151207.GA2463@minipsycho.orion>
References: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
 <1384181359-23199-2-git-send-email-jiri@resnulli.us>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73FA@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	hannes@stressinduktion.org, vyasevich@gmail.com, dcbw@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:47513 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3KKPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:12:11 -0500
Received: by mail-ee0-f48.google.com with SMTP id e49so98981eek.35
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 07:12:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73FA@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 11, 2013 at 04:07:20PM CET, David.Laight@ACULAB.COM wrote:
>> --- a/include/net/if_inet6.h
>> +++ b/include/net/if_inet6.h
>> @@ -51,7 +51,7 @@ struct inet6_ifaddr {
>>  	int			state;
>> 
>>  	__u8			dad_probes;
>> -	__u8			flags;
>> +	__u32			flags;
>> 
>>  	__u16			scope;
>
>That is adding a lot of padding.

Allright. Will reorder. Thanks

>
>	David
>
>
>
