From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: Re: [PATCH] Add IRQF_SAMPLE_RANDOM Flag to forcedeth
Date: Sat, 09 Oct 2010 21:23:01 -0600
Message-ID: <4CB13195.2070007@netscape.net>
References: <4CB0FEA6.3030206@netscape.net>	<20101010010924.GB15074@solarflare.com> <20101009.201501.214209347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr-da01.mx.aol.com ([205.188.105.143]:51010 "EHLO
	imr-da01.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756724Ab0JJDXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 23:23:11 -0400
In-Reply-To: <20101009.201501.214209347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/10 21:15, David Miller wrote:
> From: Ben Hutchings<bhutchings@solarflare.com>
> Date: Sun, 10 Oct 2010 02:09:24 +0100
>
>> Patrick Simmons wrote:
>>> This patch adds the IRQF_SAMPLE_RANDOM flag to the forcedeth driver,
>>> allowing the interrupt timing for forcedeth to be used for entropy
>>> generation.  This should help /dev/random generate more secure random
>>> numbers on machines using this driver.
>> [...]
>>
>> We don't enable this for network drivers any more because:
>>
>> 1. At high packet rates, interrupt moderation makes interrupts very
>> regular.
>> 2. At low packet rates, a malicious sender can control the interrupt
>> timing.
>
> Agreed on all counts, I'm not applying this patch.

It's enabled for other network drivers, which is where I got the idea 
from.  Has anyone actually done an experiment to see whether these two 
concerns are valid?

--Patrick

-- 
If I'm not here, I've gone out to find myself.  If I get back before I 
return, please keep me here.
