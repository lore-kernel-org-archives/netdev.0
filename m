From: Raimonds Cicans <ray@apollo.lv>
Subject: Re: r8169: fix driver drop incoming packets >= 1515 if MTU is set
 between 1515 and 1536
Date: Thu, 12 Nov 2009 00:36:05 +0200
Message-ID: <4AFB3C55.1050906@apollo.lv>
References: <4AFB0061.7020908@apollo.lv>	 <1257964419.2839.58.camel@achroite.uk.solarflarecom.com>	 <4AFB190F.2020009@apollo.lv> <1257970536.2839.73.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.apollo.lv ([80.232.168.229]:27830 "EHLO smtp2.apollo.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759511AbZKKWgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 17:36:02 -0500
In-Reply-To: <1257970536.2839.73.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings:
> On Wed, 2009-11-11 at 22:05 +0200, Raimonds Cicans wrote:
>> Ben Hutchings:
>>> On Wed, 2009-11-11 at 20:20 +0200, Raimonds Cicans wrote:
>>>> Driver drop incoming packets >=3D 1515(1) if MTU is set between 15=
15(1) and 1536.
>>>>
>>>> 1) exact number depends on some factors:
>>>> - VLAN tagged or not
>>>> - patch "r8169: Fix card drop incoming VLAN tagged MTU byte large =
jumbo frames"
>>>>   applied or not
>>> [...]
>>>
>>> MTU is a limit on transmission; it is not required to limit receive=
d
>>> frames.
>> ???
>>
>> In r8169 driver MTU is used to calculate receive buffer size.
>> Receive buffer size is used to configure hardware incoming packet fi=
lter.
>>
>> For jumbo frames:
>> Receive buffer size =3D Max frame size =3D MTU + 14 (ethernet header=
) + 4
>> (vlan header) + 4 (ethernet checksum) =3D MTU + 22
>>
>> Bug:
>> driver for all MTU up to 1536 use receive buffer size 1536
> [...]
>=20
> OK, now I understand.  =EF=BB=BFThe subject line you used is not gram=
matical and
> I originally thought you considered it a bug that the driver might
> accept packets with payload greater than MTU.

Sorry for my poor English.

> To make it clear, perhaps you could change the subject to:
> 'r8169: Fix receive buffer length when MTU is between 1515 and 1536'
> and then explain the current behaviour below that.

Ok. I will try to make new version tomorrow.

Raimonds Cicans

