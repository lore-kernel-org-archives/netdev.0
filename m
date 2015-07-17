From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 1/3] fixed_phy: handle link-down case
Date: Fri, 17 Jul 2015 14:26:02 +0300
Message-ID: <55A8E64A.3040009@list.ru>
References: <55A7C45F.1070501@list.ru> <55A7C49E.2020803@list.ru> <55A83D86.2030505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A83D86.2030505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

17.07.2015 02:25, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 16/07/15 07:50, Stas Sergeev wrote:
>>
>> Currently fixed_phy driver recognizes only the link-up state.
>> This simple patch adds an implementation of link-down state.
>> It fixes the status registers when link is down, and also allows
>> to register the fixed-phy with link down without specifying the spee=
d.
>=20
> This patch still breaks my setups here, e.g: drivers/net/dsa/bcm_sf2.=
c,
> but I will look into it.
>=20
> Do we really need this for now for your two other patches to work
> properly, or is it just nicer to have?
Yes, absolutely.
Otherwise registering fixed phy will return -EINVAL
because of the missing link speed (even though the link
is down).

Please, see what makes a problem. I can't reproduce what you report.
