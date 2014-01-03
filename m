From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 3/5] bgmac: add support for new BGMAC_CMDCFG_SR position
 on core rev >= 4
Date: Fri, 3 Jan 2014 07:05:34 +0100
Message-ID: <CACna6rznd+BKa5JYnZCQrOJF-puX35WSQdUkA9LtnsdZXzD5HQ@mail.gmail.com>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
	<1388690342-27213-3-git-send-email-hauke@hauke-m.de>
	<CACna6rz56gCNaTnvh1Dig=Dk8mE-=xK2gWuUoOMxiyUWowwXVA@mail.gmail.com>
	<52C5E727.4060603@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:47424 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaACGFf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:05:35 -0500
Received: by mail-oa0-f47.google.com with SMTP id k1so15622978oag.6
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 22:05:34 -0800 (PST)
In-Reply-To: <52C5E727.4060603@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
> On 01/02/2014 09:28 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
>> 2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
>>> The BGMAC_CMDCFG_SR register is at a different position on core rev=
 >=3D 4
>>> -#define  BGMAC_CMDCFG_SR                       0x00000800      /* =
Set to reset mode */
>>> +#define  BGMAC_CMDCFG_SR_REVO                  0x00000800      /* =
Set to reset mode, for other revs */
>>> +#define  BGMAC_CMDCFG_SR_REV4                  0x00002000      /* =
Set to reset mode, only for core rev 4 */
>>> +#define  BGMAC_CMDCFG_SR(rev)  ((rev >=3D 4) ? BGMAC_CMDCFG_SR_REV=
4 : BGMAC_CMDCFG_SR_REVO)
>>
>> If you use _REV4 for rev 4+, then what about using _REV0 for rev 0+?
>>
>> I guess REVO stands for OTHERS, but others doesn't actually mean rev=
 !=3D 4 here.
>>
>> Unless it was supposed to be 0 from the beginning and it's just a ty=
po?
>>
>> In future you may need to use _REV7 or whatever number.
>>
> This should be REV0, 0 and O are just so similar.
>
> I will also change this from rev >=3D 4 to rev =3D=3D 4, as the Broad=
com
> driver does the same.

Ahh, if this is only for rev =3D=3D 4, then maybe BGMAC_CMDCFG_SR or
BGMAC_CMDCFG_SR_REVO aren't bad after all.

It's up to you in this situation :)

--=20
Rafa=C5=82
