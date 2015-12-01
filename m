From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Tue, 1 Dec 2015 16:39:11 +0900
Message-ID: <565D4E9F.2000605@miraclelinux.com>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
 <CAPA1RqB8uc3vTOi4HXMdU3LREvmcKnUk=ygf3aax1kVZ+wcwJw@mail.gmail.com>
 <87r3j74mnh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	network dev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33499 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbbLAHjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 02:39:14 -0500
Received: by pabfh17 with SMTP id fh17so219675367pab.0
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 23:39:14 -0800 (PST)
In-Reply-To: <87r3j74mnh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Bj=C3=B8rn Mork wrote:
> =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.=
com> writes:
>=20
>>>> +static int addrconf_ifid_random(u8 *eui, struct net_device *dev)
>>> +{
>>> +       get_random_bytes(eui, 8);
>>> +       eui[0] |=3D 0x02;
>>> +       return 0;
>>> +}
>>> +
>>
>> Since random identifier is locally assigned, drop the global bit
>> instead if setting it.
>=20
> Yes, definitely. Thanks.  I'm considering reusing __ipv6_regen_rndid(=
)
> which already does this correctly, and also avoids some locally assig=
ned
> addresses with special meanings.
>=20
> Another issue with the initial RFC is that every prefix will have a n=
ew
> random ifid, which isn't necessarily what the users expect.  I wonder=
 if
> it would be acceptable to abuse the rndid field for storing a "perman=
ent"
> random ifid?

Well, I think we should introduce ifid in inet6_dev.
After that we could use it from other ifid methods.

--yoshfuji

>=20
>=20
> Bj=C3=B8rn
>=20

--=20
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
