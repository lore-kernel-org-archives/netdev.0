From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Wed, 9 Mar 2016 18:29:01 +0100
Message-ID: <56E05D5D.80604@xilinx.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
 <56DDB6CA.8000100@atmel.com> <56E04F73.6030504@xilinx.com>
 <20160309.122210.1419008371671612631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <moritz.fischer@ettus.com>,
	<cyrille.pitchen@atmel.com>, <punnaia@xilinx.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0074.outbound.protection.outlook.com ([104.47.37.74]:22184
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753756AbcCIR3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 12:29:16 -0500
In-Reply-To: <20160309.122210.1419008371671612631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9.3.2016 18:22, David Miller wrote:
> From: Michal Simek <michal.simek@xilinx.com>
> Date: Wed, 9 Mar 2016 17:29:39 +0100
>=20
>> On 7.3.2016 18:13, Nicolas Ferre wrote:
>>> Le 07/03/2016 17:17, Moritz Fischer a =E9crit :
>>>> Hi Nicolas,
>>>>
>>>> this series deals with most of the checkpatch warnings
>>>> generated for macb. There are two BUG_ON()'s that I didn't touch, =
yet,
>>>> that were suggested by checkpatch, that I can address in a follow =
up
>>>> commit if needed.
>>>> Let me know if you want me to split the fixes differently or squas=
h
>>>> them into one commit.
>>>
>>> Hi,
>>>
>>> I'm not usually fond of this type of patches, but I must admit that=
 this
>>> series corrects some style issues.
>>>
>>> So, I would like more feedback from Michal and Cyrille as these cha=
nges
>>> may delay some of the not-merged-yet features or more important
>>> work-in-progress on their side.
>>>
>>> On the other hand, if we all think it's a calm period for this macb
>>> driver, we may find interesting to merge some "cleanup and style"
>>> enhancements.
>>
>> Not a problem with merging cleanups in general. We have several out =
of
>> tree patches but doesn't make sense to to wait.
>> I wasn't in cc for the series but I don't like this change to be the
>> part of cleanup series.
>>
>> 	mac =3D of_get_mac_address(np);
>>  	if (mac)
>> -		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
>> +		ether_addr_copy(bp->dev->dev_addr, mac);
>=20
> Why?  This is what we tell people to use.

I would expect this as separate patch not the part of one huge cleanup
patch which does just comment and space cleanups.

Thanks,
Michal
