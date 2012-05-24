From: Ben Greear <greearb@candelatech.com>
Subject: Re: net/wanrouter?
Date: Thu, 24 May 2012 09:32:43 -0700
Message-ID: <4FBE62AB.6000900@candelatech.com>
References: <1337708034.3432.0.camel@joe2Laptop>  <4FBE3CFC.6070103@computer.org>  <20120524091310.1c01577e@nehalam.linuxnetplumber.net> <1337876577.5070.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50465 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926Ab2EXQcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 12:32:54 -0400
In-Reply-To: <1337876577.5070.7.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2012 09:22 AM, Joe Perches wrote:
> On Thu, 2012-05-24 at 09:13 -0700, Stephen Hemminger wrote:
>> On Thu, 24 May 2012 15:51:56 +0200
>> Jan Ceuleers<jan.ceuleers@computer.org>  wrote:
>>
>>> On 05/22/2012 07:33 PM, Joe Perches wrote:
>>>> Does anyone still use this?
>>>
>>> I have the hardware (a Sangoma ADSL PCI card) but am no longer using it.
>>> Also, as I remember, Sangoma stopped contributing to the upstream driver
>>> many years ago while still actively developing the out-of-tree version.
>>
>> The wanrouter code hasn't supported Sangoma hardware for a long time,
>> it got removed early in 2.6.
>>
>> There are a bunch of old T1 and T3 cards there but I doubt any of them
>> are still for sale. But somebody is probably still using them.
>
> I'm sure people are still using token ring
> too, just not with recent kernels.
>
> I think wanrouter is old and dusty and can
> be removed just like TR.

I think you should mark it deprecated for a release or
two first, just in case.  Unless it is obviously very
broken or holding up other important work.

Lots of people that might be using this do not follow
the netdev mailing list...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
