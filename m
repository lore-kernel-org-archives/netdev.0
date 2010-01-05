From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Tue, 05 Jan 2010 10:20:30 -0800
Message-ID: <4B4382EE.4080706@redfish-solutions.com>
References: <4B298118.2000608@redfish-solutions.com> <200912221328.56573.schmto@hrz.tu-chemnitz.de> <4B32A33C.6050507@redfish-solutions.com> <201001051635.59914.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:36123 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753978Ab0AESUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 13:20:38 -0500
In-Reply-To: <201001051635.59914.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2010 07:35 AM, Torsten Schmidt wrote:
>> Can you extend the patch to include classify_1d() in net/mac80211/wme.c?
>>
>> I'm thinking:
>>
>>          }
>>
>> -        if (dscp & 0x1c)
>> +#if !defined(CONFIG_IP_DIFFSERV_COMPLIANT)
>> +        if (IPTOS_TOS(dscp) & ~IPTOS_LOWCOST)
>>                  return 0;
>> +#endif
>>          return dscp >> 5;
>>  }
> This code segment seems to be older stuff. Its not in 2.6.32. 
> 
> Torsten 

I'm running 2.6.27.42.


