From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 1/2] bridge: display IFLA_BRPORT_LEARNING value
Date: Tue, 20 May 2014 18:11:59 +0200
Message-ID: <537B7ECF.2020207@6wind.com>
References: <1400578650-6917-1-git-send-email-nicolas.dichtel@6wind.com> <537B7130.2050504@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:65104 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbaETQMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 12:12:03 -0400
Received: by mail-we0-f176.google.com with SMTP id q59so740997wes.7
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 09:12:01 -0700 (PDT)
In-Reply-To: <537B7130.2050504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/05/2014 17:13, Vlad Yasevich a =E9crit :
> Hi Nicolas
>
> On 05/20/2014 05:37 AM, Nicolas Dichtel wrote:
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   bridge/link.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/bridge/link.c b/bridge/link.c
>> index 38dfaea2e180..1632bc16803f 100644
>> --- a/bridge/link.c
>> +++ b/bridge/link.c
>> @@ -185,6 +185,9 @@ int print_linkinfo(const struct sockaddr_nl *who=
,
>>   				if (prtb[IFLA_BRPORT_FAST_LEAVE])
>>   					print_onoff(fp, "fastleave",
>>   						    rta_getattr_u8(prtb[IFLA_BRPORT_FAST_LEAVE]));
>> +				if (prtb[IFLA_BRPORT_LEARNING])
>> +					print_onoff(fp, "learning",
>> +						    rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING]));
>>   			}
>>   		} else
>>   			print_portstate(fp, rta_getattr_u8(tb[IFLA_PROTINFO]));
>>
>
> Already proposed. See http://patchwork.ozlabs.org/patch/350291/
Sorry for the noise, I've looked too quickly the patchwork.


Regards,
Nicolas
