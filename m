From: akepner@sgi.com
Subject: Re: Help interpreting ethtool -S for tg3 (rx_discards and such)
Date: Thu, 9 Sep 2004 09:47:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0409090940330.14625-100000@localhost.localdomain>
References: <4140801F.4050208@baligant.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Fran=E7ois_Baligant?= <francois@baligant.net>
In-Reply-To: <4140801F.4050208@baligant.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004, Fran=E7ois Baligant wrote:

> Hi,
>=20
> We have a tg3 NIC under heavy load (30megabit/s, around 15k to 20k=20
> packet/sec)
>=20
> Under 2.6.7, the NIC behaves quite correctly (except errors see below)
> Under 2.6.8, the NIC's link will go down after some time and not come u=
p=20
> again (rx_discards grow more quickly than in 2.6.7)
> Under 2.6.9-rc1, the NIC will go down from time to time also but recove=
r=20
> after 5 seconds and link goes up again (dito)
>=20
> Should I worry about the errors in ethtool, like rx_discards ? What doe=
s=20
> it mean ? Can i tune something to avoid them ? (netdev backlog?)

I believe that when rx_discards increments, it means that the card=20
dropped the packet due to a resource constraint.=20

I've seen similar behavior (but at much higher data rates.) In my=20
case, enabling h/w flow control fixed things. If it's possible to use=20
h/w flow control in your configuration, then you might give that a try.

>=20
> Is there any way to lower the amount of interrupt needed to handle this=
=20
> load? (it's eating quite a lot of CPU)
> ....

That is a _feature_ of NAPI ;-)

--=20
Arthur
