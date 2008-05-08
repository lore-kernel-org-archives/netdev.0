From: Patrick McHardy <kaber@trash.net>
Subject: Re: [MACVLAN]: Fix memleak on device removal/crash on module removal
Date: Thu, 08 May 2008 17:34:02 +0200
Message-ID: <48231D6A.9020902@trash.net>
References: <48215DAC.1070704@trash.net>	<48222727.2090606@candelatech.com> <20080508.011405.223859547.davem@davemloft.net> <48231BD9.5090200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36525 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbYEHPeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 11:34:37 -0400
In-Reply-To: <48231BD9.5090200@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
>>>>     [MACVLAN]: Fix memleak on device removal/crash on module removal
>>>>       
>>> Thanks.  I just tested this on 2.6.23 and it seems to fix the crash.
>>>     
>>
>> I've applied this to net-2.6, and will queue it up for net-2.6
>> as well.
>>
>> Thanks again!
>>   
> 
> This might be worth adding to any/all 2.6.23+ stable series since it's a 
> reliable kernel crash on module unload.

I don't think there is anyone maintaining the stable kernels
before stable-2.6.25 (for which I think Dave already queued
it up, above appears to be a typo).

> I'm not sure if anyone else is really using mac-vlans much yet though...

I know of a few users, but not too many I guess. The fix
is obvious though so it doesn't hurt for -stable in any
case.

