From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Should "N/A" dust bunnies be swept from fw_version?
Date: Fri, 18 Nov 2011 11:23:46 -0800
Message-ID: <4EC6B0C2.8080605@hp.com>
References: <4EC5984D.5070501@hp.com> <1321575574.2749.55.camel@bwh-desktop> <4EC6AD7C.2070307@hp.com> <20111118.141046.1309959676401370888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:20297 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626Ab1KRTXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 14:23:48 -0500
In-Reply-To: <20111118.141046.1309959676401370888.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 11:10 AM, David Miller wrote:
> From: Rick Jones<rick.jones2@hp.com>
> Date: Fri, 18 Nov 2011 11:09:48 -0800
>
>> On 11/17/2011 04:19 PM, Ben Hutchings wrote:
>>> On Thu, 2011-11-17 at 15:27 -0800, Rick Jones wrote:
>>>> In the discussion on "enable virtio_net to return bus_info in ethtool
>>>> -i
>>>> consistent with emulated NICs" Ben Hutchings had the following
>>>> feedback
>>>> on what might go into bus_info:
>>>>
>>>>> Please use the existing 'not implemented' value, which is the empty
>>>>> string.  If you think ethtool should print some helpful message
>>>>> instead
>>>>> of an empty string, please submit a patch for ethtool.
>>>>
>>>> When I was sweeping in the .get_drvinfo routines, I noticed many
>>>> drivers
>>>> would return "N/A" for fw_version - presumably they were drivers for
>>>> cards without firmware.  Should those be removed to have the
>>>> fw_version
>>>> be the empty string, or should those sleeping dust bunnies be allowed
>>>> to
>>>> lie?
>>>
>>> I much prefer the empty string; the ethtool utility can turn that into
>>> a
>>> user-friendly placeholder if it's considered confusing.
>>
>> Any other opinions out there?  Anyone? Anyone?-)
>
> I agree with Ben, just provide the empty string.

OK, when I have time to pick-up my broom, I'll do some additional sweeping.

rick
