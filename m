From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 3/5] bgmac: add support for new BGMAC_CMDCFG_SR position
 on core rev >= 4
Date: Thu, 02 Jan 2014 23:24:39 +0100
Message-ID: <52C5E727.4060603@hauke-m.de>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>	<1388690342-27213-3-git-send-email-hauke@hauke-m.de> <CACna6rz56gCNaTnvh1Dig=Dk8mE-=xK2gWuUoOMxiyUWowwXVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:52616 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbaABWYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 17:24:46 -0500
In-Reply-To: <CACna6rz56gCNaTnvh1Dig=Dk8mE-=xK2gWuUoOMxiyUWowwXVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2014 09:28 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2014/1/2 Hauke Mehrtens <hauke@hauke-m.de>:
>> The BGMAC_CMDCFG_SR register is at a different position on core rev =
>=3D 4
>> -#define  BGMAC_CMDCFG_SR                       0x00000800      /* S=
et to reset mode */
>> +#define  BGMAC_CMDCFG_SR_REVO                  0x00000800      /* S=
et to reset mode, for other revs */
>> +#define  BGMAC_CMDCFG_SR_REV4                  0x00002000      /* S=
et to reset mode, only for core rev 4 */
>> +#define  BGMAC_CMDCFG_SR(rev)  ((rev >=3D 4) ? BGMAC_CMDCFG_SR_REV4=
 : BGMAC_CMDCFG_SR_REVO)
>=20
> If you use _REV4 for rev 4+, then what about using _REV0 for rev 0+?
>=20
> I guess REVO stands for OTHERS, but others doesn't actually mean rev =
!=3D 4 here.
>=20
> Unless it was supposed to be 0 from the beginning and it's just a typ=
o?
>=20
> In future you may need to use _REV7 or whatever number.
>=20
This should be REV0, 0 and O are just so similar.

I will also change this from rev >=3D 4 to rev =3D=3D 4, as the Broadco=
m
driver does the same.

Hauke
