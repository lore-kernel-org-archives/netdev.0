From: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Subject: Re: [PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 4 Aug 2015 22:07:45 +0000
Message-ID: <55C137B0.5020302@alliedtelesis.co.nz>
References: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
 <20150803223158.40ae7d52@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:36177 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbbHDWHv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 18:07:51 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 834C2806B6
	for <netdev@vger.kernel.org>; Wed,  5 Aug 2015 10:07:49 +1200 (NZST)
In-Reply-To: <20150803223158.40ae7d52@urahara>
Content-Language: en-US
Content-ID: <1CD6D67E1E5E86418EDB829DE6E5BEBC@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Given that fib_nhs is currently an int I would rather keep live_nexthops 
also as an int to match, probably fib_nhs could at least be set as 
unsigned or changed to u16 or even u8 perhaps.

Best Regards,
Richard

On 08/04/2015 05:31 PM, Stephen Hemminger wrote:
> On Tue,  4 Aug 2015 13:28:47 +1200
> Richard Laing <richard.laing@alliedtelesis.co.nz> wrote:
>
>> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
>> index 5fa643b..7db9f72 100644
>> --- a/include/net/ip_fib.h
>> +++ b/include/net/ip_fib.h
>> @@ -117,6 +117,8 @@ struct fib_info {
>>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>>   	int			fib_power;
>>   #endif
>> +	/* Cache the number of live nexthops for flow based ECMP calculation. */
>> +	int			live_nexthops;
> unsigned or u16 ? rather than risking sign issues.

-- 

*Richard Laing*
Software Team Leader*
Allied Telesis Labs*| 27 Nazareth Ave | Christchurch 8024 | New Zealand
Phone: +64 3 3393000 | DDI: +64 3 339 9248 | Web: *alliedtelesis.com 
<http://alliedtelesis.com/>*<skype:andrewriddell3?chat>


http://productselector.alliedtelesis.eu/ 
<http://productselector.alliedtelesis.eu/>