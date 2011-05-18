From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a 'bitwise'
 type
Date: Tue, 17 May 2011 22:59:02 -0400
Message-ID: <4DD335F6.3010501@garzik.org>
References: <1305666379.2848.45.camel@bwh-desktop> <20110517.171412.1017451005914294196.davem@davemloft.net> <4DD3285D.6010506@garzik.org> <20110517.222302.158419141035335293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44002 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756487Ab1ERC7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 22:59:05 -0400
Received: by gyd10 with SMTP id 10so401801gyd.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 19:59:03 -0700 (PDT)
In-Reply-To: <20110517.222302.158419141035335293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2011 10:23 PM, David Miller wrote:
> From: Jeff Garzik<jeff@garzik.org>
>
>> On 05/17/2011 05:14 PM, David Miller wrote:
>>> Accept that the compiler currently doesn't want to allow enums to be
>>> used as bit-masks, don't paper around it.
>>
>> This practice is all over the kernel.
>>
>> It's a bit silly to make such a big deal, because of that.
>
> "We do something stupid everywhere" is never a good
> argument for anything.

grepping across the kernel, it is clearly a useful shorthand technique 
for defining typed, named constants, including bitmasks, used widely 
across multiple subsystems, drivers and include/linux.

Given that this technique has passed review time and again, and that 
kernel hackers -do- find it useful for valid reasons, I guess the only 
remaining defense is to call something "stupid."

	Jeff



