From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] mvneta: use inband status only when link type is
 "auto"
Date: Thu, 09 Jul 2015 14:14:11 -0700
Message-ID: <559EE423.9060503@gmail.com>
References: <559EB0A4.5080101@list.ru> <559EB22E.7070607@list.ru> <559EBAFE.6040705@gmail.com> <559ED8F1.7050609@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <559ED8F1.7050609@list.ru>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/15 13:26, Stas Sergeev wrote:
> 09.07.2015 21:18, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On 09/07/15 10:41, Stas Sergeev wrote:
>>> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band lin=
k
>>> state
>>> signaling") implemented the link parameters auto-negotiation
>>> unconditionally.
>>> Unfortunately it appears that some HW that implements SGMII protoco=
l,
>>> doesn't generate the inband status, so it is not possible to
>>> auto-negotiate
>>> anything with such HW.
>> What is the purpose of using the in-band status in the first place i=
f
>> you end-up having to specify a 'fixed-link' property which contains =
most
>> of the link parameters: speed, duplex etc...?
> You don't have to.
> My config from today is as simple as:
>=20
> fixed-link {
>   link =3D "auto";
> };
>=20
> and that's all.
> Without my today's patch, only 'speed' is a mandatory - not too much.

That makes me think that 'fixed-link' is not exactly what you want then=
,
you would probably want something like "marvell,use-in-band-status" or
something like this. It could be a more generic property that is not
Marvell specific after all, that would be fine.
--=20
=46lorian
