From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 10/12] net: dsa: support switchdev ageing time
 attr
Date: Mon, 18 Jul 2016 21:26:00 -0700
Message-ID: <ec4db799-a764-d029-80fb-9a56338f7bc5@gmail.com>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-11-vivien.didelot@savoirfairelinux.com>
 <20160719032415.GD9111@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719032415.GD9111@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/07/2016 =C3=A0 20:24, Andrew Lunn a =C3=A9crit :
> On Mon, Jul 18, 2016 at 08:45:38PM -0400, Vivien Didelot wrote:
>> Add a new function for DSA drivers to handle the switchdev
>> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME attribute.
>>
>> The ageing time is passed as milliseconds.
>>
>> Also because we can have multiple logical bridges on top of a physic=
al
>> switch and ageing time are switch-wide, call the driver function wit=
h
>> the fastest ageing time in use on the chip instead of the requested =
one.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  include/net/dsa.h |  2 ++
>>  net/dsa/slave.c   | 41 +++++++++++++++++++++++++++++++++++++++++
>=20

Hi Andrew,

> Hi Florian
>=20
> It looks like the SF2 can do fast ageing per port. What i don't see i=
f
> what configuration options you have. Can you get the fast and the
> normal age time per port? Or is it global?

The normal ageing is global and the value needs to be programmed in
seconds, can can range from 10 to 1,048,575 (encoded on 20 bits). The
fast-ageing can actually be per-port, per-VLAN id, for just dynamic or
static entries etc. and is just a poor name for a flush based on any of
these criteria.
--=20
=46lorian
