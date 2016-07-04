From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Mon, 4 Jul 2016 14:40:28 -0700
Message-ID: <577AD7CC.9010908@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
 <20160628010551.GD26597@lunn.ch>
 <CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
 <20160629.061201.2186992042260603628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33036 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbcGDVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:40:31 -0400
Received: by mail-oi0-f65.google.com with SMTP id w141so24994984oia.0
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:40:30 -0700 (PDT)
In-Reply-To: <20160629.061201.2186992042260603628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/06/2016 03:12, David Miller a =C3=A9crit :
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 27 Jun 2016 18:19:28 -0700
>=20
>> 2016-06-27 18:05 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
>>> On Mon, Jun 27, 2016 at 05:52:37PM -0700, Florian Fainelli wrote:
>>>> Hi all,
>>>>
>>>> This patch series adds support for platform data using the new cod=
e from
>>>> net/dsa/dsa2.c. The motivation behind this is that we have a bit o=
f in tree
>>>> platforms (ar7, bcm47xx, x86, others) that could be benefiting fro=
m the new
>>>> dsa_register_switch() API model but do not support Device Tree, no=
r is there a
>>>> plan to bring Device Tree to these platforms (time vs. benefits).
>>>
>>> Hi Florian
>>>
>>> Please could you convert an in tree device to actually use this.
>>
>> Sure, I don't think there are going to be in tree users who need the
>> dsa2_port_link information most of what we have is typically single
>> chip, and so in that case, we can even re-use the existing
>> dsa_platform_data.
>=20
> I assume therefore that this series will be resubmitted with an
> accompanying example in-tree conversion.
>=20

That is correct, although patches 1-4 could be applied immediately as
they are mostly preparatory steps to patches 5-6, I don't mind resendin=
g
this at a later time though (probably for the next net-next merge windo=
w
I assume).
--=20
=46lorian
