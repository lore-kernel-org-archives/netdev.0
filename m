From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Should "N/A" dust bunnies be swept from fw_version?
Date: Fri, 18 Nov 2011 11:09:48 -0800
Message-ID: <4EC6AD7C.2070307@hp.com>
References: <4EC5984D.5070501@hp.com> <1321575574.2749.55.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:19735 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab1KRTJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 14:09:50 -0500
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id B7B2038663
	for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 19:09:49 +0000 (UTC)
Received: from [16.89.64.213] (tardy.cup.hp.com [16.89.64.213])
	by g4t0009.houston.hp.com (Postfix) with ESMTP id 8EDB9C038
	for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 19:09:49 +0000 (UTC)
In-Reply-To: <1321575574.2749.55.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2011 04:19 PM, Ben Hutchings wrote:
> On Thu, 2011-11-17 at 15:27 -0800, Rick Jones wrote:
>> In the discussion on "enable virtio_net to return bus_info in ethtool -i
>> consistent with emulated NICs" Ben Hutchings had the following feedback
>> on what might go into bus_info:
>>
>>> Please use the existing 'not implemented' value, which is the empty
>>> string.   If you think ethtool should print some helpful message instead
>>> of an empty string, please submit a patch for ethtool.
>>
>> When I was sweeping in the .get_drvinfo routines, I noticed many drivers
>> would return "N/A" for fw_version - presumably they were drivers for
>> cards without firmware.  Should those be removed to have the fw_version
>> be the empty string, or should those sleeping dust bunnies be allowed to
>> lie?
>
> I much prefer the empty string; the ethtool utility can turn that into a
> user-friendly placeholder if it's considered confusing.

Any other opinions out there?  Anyone? Anyone?-)

rick jones
