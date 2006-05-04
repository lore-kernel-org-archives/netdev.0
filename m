From: "George P Nychis" <gnychis@cmu.edu>
Subject: Re: how to change classful netem loss probability?
Date: Thu, 4 May 2006 19:35:08 -0400 (EDT)
Message-ID: <32893.128.2.140.234.1146785708.squirrel@128.2.140.234>
References: <444FF846.7050600@cmu.edu>
	<32923.128.2.140.234.1146187103.squirrel@128.2.140.234>
	<20060428102421.7d304ca6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20060428102421.7d304ca6@localhost.localdomain>
To: "Stephen Hemminger" <shemminger@osdl.org>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

where did you send this patch?

I don't think I ever got it

> Loss was broken, patch sent.
>=20
> The following works now:
>=20
> # tc qdisc add dev eth1 root handle 1:0 netem loss 20%
>=20
> # tc qdisc add dev eth1 parent 1:1 handle 10: tbf \ rate 256kbit buffer
> 1600 limit 3000 # ping -f -c 1000 shell
>=20
> 1000 packets transmitted, 781 received, 21% packet loss, time 3214ms rt=
t
> min/avg/max/mdev =3D 0.187/0.398/3.763/0.730 ms, ipg/ewma 3.217/0.538 m=
s
>=20
> # tc qdisc chang dev eth1 handle 1: netem loss 1% # ping -f -c 1000 she=
ll
>=20
> 1000 packets transmitted, 990 received, 1% packet loss, time 2922ms rtt
> min/avg/max/mdev =3D 0.187/2.739/3.298/0.789 ms, ipg/ewma 2.924/2.084 m=
s
>=20
>=20
>=20
>=20


--=20
