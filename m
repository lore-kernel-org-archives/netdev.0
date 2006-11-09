From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Intel 82559 NIC corrupted EEPROM
Date: Thu, 09 Nov 2006 09:03:34 -0800
Message-ID: <45535F66.8010803@intel.com>
References: <454B7C3A.3000308@privacy.net> <454BF0F1.5050700@zytor.com> <45506C9A.5010009@privacy.net> <4551B7B8.8080601@privacy.net> <45520337.2070303@intel.com> <45531C42.3070503@privacy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hpa@zytor.com, saw@saw.sw.com.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55720 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1424134AbWKIREO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 12:04:14 -0500
To: John <me@privacy.net>
In-Reply-To: <45531C42.3070503@privacy.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John wrote:
> Auke Kok wrote:
> 
>> This is what I was afraid of: even though the code allows you to 
>> bypass the EEPROM checksum, the probe fails on a further check to see 
>> if the MAC address is valid.
>>
>> Since something with this NIC specifically made the EEPROM return all 
>> 0xff's, the MAC address is automatically invalid, and thus probe fails.
> 
> I don't understand why you think there is something wrong with a
> specific NIC?

that was completely not my point - I was merely trying to point out that the original 
problem causes a cascade of error events later on, and bypassing the eeprom check in 
this case didn't help you at all. Something is wrong in the driver, but I don't 
understand yet why it only affects one of the 3 nics in your system.

> In 2.6.14.7, e100.ko fails to read the EEPROM on 0000:00:08.0 (eth0)
> In 2.6.18.1, e100.ko fails to read the EEPROM on 0000:00:09.0 (eth1)

almost sounds like a bug got fixed and it introduced a regression. this wouldn't be the 
right time to pull out git-bisect would it? even loading 2.6.15, 2.6.16, 2.6.17 on it 
would give us some good information.


Cheers,

Auke
