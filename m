From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: dsa: fix filling routing table from OF description
Date: Sat, 04 Apr 2015 14:49:45 -0700
Message-ID: <55205C79.8050308@gmail.com>
References: <1516684.D2TdrA1BPT@kuro.zhome>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
To: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	netdev@vger.kernel.org, Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1516684.D2TdrA1BPT@kuro.zhome>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/04/2015 14:46, Pavel Nakonechny a =C3=A9crit :
> According to description in 'include/net/dsa.h', in cascade switches
> configurations where there are more than one interconnected devices,
> 'rtable' array in 'dsa_chip_data' structure is used to indicate which
> port on this switch should be used to send packets to that are destin=
ed
> for corresponding switch.
>=20
> However, dsa_of_setup_routing_table() fills 'rtable' with port number=
s
> of the _target_ switch, but not current one.
>=20
> This commit removes redundant devicetree parsing and adds needed port
> number as a function argument. So dsa_of_setup_routing_table() now ju=
st
> looks for target switch number by parsing parent of 'link' device nod=
e.
>=20
> To remove possible misunderstandings with the way of determining targ=
et
> switch number, a corresponding comment was added to the source code a=
nd
> to the DSA device tree bindings documentation file.
>=20
> This was tested on a custom board with two Marvell 88E6095 switches w=
ith
> following corresponding routing tables: { -1, 10 } and { 8, -1 }.
>=20
> Signed-off-by: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--
=46lorian
