From: "xerces8" <xerces8@butn.net>
Subject: Re: "Listenless" TCP over NAT?
Date: Fri, 05 Sep 2008 16:26:36 +0200
Message-ID: <WorldClient-F200809051626.AA26360181@butn.net>
References: <WorldClient-F200809051345.AA45130148@butn.net> <5f1c7b80099fb4aa3ad56e830aa525d1@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Linux Netdev" <netdev@vger.kernel.org>,
	"Linux Networking" <linux-net@vger.kernel.org>
To: "=?iso-8859-1?Q?R=E9mi?= Denis-Courmont" <rdenis@simphalempin.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <5f1c7b80099fb4aa3ad56e830aa525d1@chewa.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi Denis-Courmont wrote:

> Linux TCP/IP does allow this at the end nodes.
>=20
> However, whether it works on the NAT model. Many NAPT and firewalling=
 boxes
> will reset the TCP session if you try to do TCP simultaneous open. Be=
sides,
> you need to be able to predict your source port number, which again i=
s not
> always possible depending on the NAPT implementation.
>=20
>=20
> As far as I can tell, this is simply way too failure prone in real li=
fe.
> Using some form of UDP encapsulation, such as ICE, Teredo, IPsec-in-U=
DP,
> etc works A LOT better, although not always either.

Yes, but that requires either additional drivers or privileges, while
TCP simultaneous open works without all that.

Thanks for giving me the name of this thing ;-)
I will do some experimenting at home (there goes the weekend...)

Regards,
David


