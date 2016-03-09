From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Wed, 09 Mar 2016 12:22:10 -0500 (EST)
Message-ID: <20160309.122210.1419008371671612631.davem@davemloft.net>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
	<56DDB6CA.8000100@atmel.com>
	<56E04F73.6030504@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.ferre@atmel.com, moritz.fischer@ettus.com,
	cyrille.pitchen@atmel.com, punnaia@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933264AbcCIRWN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:22:13 -0500
In-Reply-To: <56E04F73.6030504@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Michal Simek <michal.simek@xilinx.com>
Date: Wed, 9 Mar 2016 17:29:39 +0100

> On 7.3.2016 18:13, Nicolas Ferre wrote:
>> Le 07/03/2016 17:17, Moritz Fischer a =E9crit :
>>> Hi Nicolas,
>>>
>>> this series deals with most of the checkpatch warnings
>>> generated for macb. There are two BUG_ON()'s that I didn't touch, y=
et,
>>> that were suggested by checkpatch, that I can address in a follow u=
p
>>> commit if needed.
>>> Let me know if you want me to split the fixes differently or squash
>>> them into one commit.
>>=20
>> Hi,
>>=20
>> I'm not usually fond of this type of patches, but I must admit that =
this
>> series corrects some style issues.
>>=20
>> So, I would like more feedback from Michal and Cyrille as these chan=
ges
>> may delay some of the not-merged-yet features or more important
>> work-in-progress on their side.
>>=20
>> On the other hand, if we all think it's a calm period for this macb
>> driver, we may find interesting to merge some "cleanup and style"
>> enhancements.
>=20
> Not a problem with merging cleanups in general. We have several out o=
f
> tree patches but doesn't make sense to to wait.
> I wasn't in cc for the series but I don't like this change to be the
> part of cleanup series.
>=20
> 	mac =3D of_get_mac_address(np);
>  	if (mac)
> -		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
> +		ether_addr_copy(bp->dev->dev_addr, mac);

Why?  This is what we tell people to use.
