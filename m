From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Wed, 09 Mar 2016 15:26:41 -0500 (EST)
Message-ID: <20160309.152641.1788526652068750778.davem@davemloft.net>
References: <56E04F73.6030504@xilinx.com>
	<20160309.122210.1419008371671612631.davem@davemloft.net>
	<56E05D5D.80604@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.ferre@atmel.com, moritz.fischer@ettus.com,
	cyrille.pitchen@atmel.com, punnaia@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753847AbcCIU0o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 15:26:44 -0500
In-Reply-To: <56E05D5D.80604@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Simek <michal.simek@xilinx.com>
Date: Wed, 9 Mar 2016 18:29:01 +0100

> On 9.3.2016 18:22, David Miller wrote:
>> From: Michal Simek <michal.simek@xilinx.com>
>> Date: Wed, 9 Mar 2016 17:29:39 +0100
>>=20
>>> On 7.3.2016 18:13, Nicolas Ferre wrote:
>>>> Le 07/03/2016 17:17, Moritz Fischer a =E9crit :
>>>>> Hi Nicolas,
>>>>>
>>>>> this series deals with most of the checkpatch warnings
>>>>> generated for macb. There are two BUG_ON()'s that I didn't touch,=
 yet,
>>>>> that were suggested by checkpatch, that I can address in a follow=
 up
>>>>> commit if needed.
>>>>> Let me know if you want me to split the fixes differently or squa=
sh
>>>>> them into one commit.
>>>>
>>>> Hi,
>>>>
>>>> I'm not usually fond of this type of patches, but I must admit tha=
t this
>>>> series corrects some style issues.
>>>>
>>>> So, I would like more feedback from Michal and Cyrille as these ch=
anges
>>>> may delay some of the not-merged-yet features or more important
>>>> work-in-progress on their side.
>>>>
>>>> On the other hand, if we all think it's a calm period for this mac=
b
>>>> driver, we may find interesting to merge some "cleanup and style"
>>>> enhancements.
>>>
>>> Not a problem with merging cleanups in general. We have several out=
 of
>>> tree patches but doesn't make sense to to wait.
>>> I wasn't in cc for the series but I don't like this change to be th=
e
>>> part of cleanup series.
>>>
>>> 	mac =3D of_get_mac_address(np);
>>>  	if (mac)
>>> -		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
>>> +		ether_addr_copy(bp->dev->dev_addr, mac);
>>=20
>> Why?  This is what we tell people to use.
>=20
> I would expect this as separate patch not the part of one huge cleanu=
p
> patch which does just comment and space cleanups.

That is true.
