From: Ben Greear <greearb@candelatech.com>
Subject: Re: [MACVLAN]: Fix memleak on device removal/crash on module removal
Date: Thu, 08 May 2008 08:27:21 -0700
Message-ID: <48231BD9.5090200@candelatech.com>
References: <48215DAC.1070704@trash.net>	<48222727.2090606@candelatech.com> <20080508.011405.223859547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:40304 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbYEHP10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 11:27:26 -0400
In-Reply-To: <20080508.011405.223859547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Wed, 07 May 2008 15:03:19 -0700
>
>   
>> Patrick McHardy wrote:
>>     
>>> ------------------------------------------------------------------------
>>>
>>> commit 2fe876e51d1f053b55d8d50c3733b136b6add016
>>> Author: Patrick McHardy <kaber@trash.net>
>>> Date:   Wed May 7 09:43:05 2008 +0200
>>>
>>>     [MACVLAN]: Fix memleak on device removal/crash on module removal
>>>       
>> Thanks.  I just tested this on 2.6.23 and it seems to fix the crash.
>>     
>
> I've applied this to net-2.6, and will queue it up for net-2.6
> as well.
>
> Thanks again!
>   

This might be worth adding to any/all 2.6.23+ stable series since it's a 
reliable kernel crash on module unload.

I'm not sure if anyone else is really using mac-vlans much yet though...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


