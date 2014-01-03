From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Fri, 3 Jan 2014 07:18:54 +0100
Message-ID: <CACna6rz-R0=L9ZhfV13R_9wvG0FMowmx_YYgdXYM7EaSkXDgmw@mail.gmail.com>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
	<1388690342-27213-5-git-send-email-hauke@hauke-m.de>
	<CACna6rxrOOcb=xbeCytjWALAPOAj-P7Js5Xe7L1ykCimmDa4Sw@mail.gmail.com>
	<52C5E67B.9070306@hauke-m.de>
	<CACna6rzgno_pQQkP018snvS7rKDgoNzaufx4WphEnOXhs53v0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:45460 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaACGSy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:18:54 -0500
Received: by mail-oa0-f47.google.com with SMTP id k1so15723946oag.34
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 22:18:54 -0800 (PST)
In-Reply-To: <CACna6rzgno_pQQkP018snvS7rKDgoNzaufx4WphEnOXhs53v0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/3 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> 2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
>> On 01/02/2014 09:40 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>>>  > +       if (ci->id =3D=3D BCMA_CHIP_ID_BCM4707 ||
>>>> +           ci->id =3D=3D BCMA_CHIP_ID_BCM53018) {
>>>
>>> Please add a missing
>>> if (bgmac->phyaddr !=3D BGMAC_PHY_NOREGS)
>>> return;
>>> at the beginning of this 4707/53018 block
>>
>> Why should I add that there?
>
> This is what I can see in etcgmac.c version:
> * $Id: etcgmac.c 414031 2013-07-23 10:54:51Z $

Hm, this is weird. I think this
* $Id: etcgmac.c 414031 2013-07-23 10:54:51Z $
is not any version, but just a timestamp of executing some cleaning-scr=
ipt.

Anyway, your reference code is 6.37.14.62:
https://github.com/RMerl/asuswrt-merlin/blob/master/release/src-rt-6.x.=
4708/include/epivers.h

And mine is 6.37.14.34 (GPL_RT_AC68U_30004374205.zip).

So it seems your is newer one...

OK, leave this code like it is, ignore that my comment for now.
