From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 31 Aug 2004 22:14:38 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408312214.44701.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4134C1A7.50600@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2369908.xRTpSoHTD6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, acx100-devel@lists.sourceforge.net,
        prism54-devel@prism54.org, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <4134C1A7.50600@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2369908.xRTpSoHTD6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 31 August 2004 21:21, Jeff Garzik wrote:
JG> Denis Vlasenko wrote:
JG> > I think 'senior' network guys are in position to decide upon which
JG> > of currently available 802.11 stacks we should continue to work.
JG> > (Atheros has one, said to be derived from BSD, is there any others?)
JG>
JG>
JG> Already have.  Start with the code in wireless-2.6 -- HostAP -- and use
JG> DaveM's 802.11 stack template as a model for actually integrating 802.11
JG> very tightly with the rest of the net stack.
JG>
JG>
 http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-=
p8
0211.tar.bz2 JG>
JG>  Jeff

This stack raises many questions.

The very idea to implement generic softmac is pretty good.

So, first questions:

=2D it defines structures that was present in Jean's wireless extensions. S=
o,=20
will it replace Jean's wireless extensions, merge with it, or some other=20
relationship? Partually, I don't like to see definitions for .11 header and=
=20
field constants in 2 includes.

=2D QoS stuff is not defined. I suppose recent cards will all support WME a=
nd/or=20
TGe. It is easy to add "QoS control" field to header and new frame types, b=
ut=20
it is harder to formally define how PHY should handle it. And, TGe is big=20
story on itself, with all its HCCA, block ack, etc. I also think that QoS, =
as=20
it is defined in TGe, required driver to have several tx queues and=20
start/stop them separately. Is anyone working on it? I'll be glad to join.

=2D Security is not up-to date either. We need .1x, EAS, TKIP etc. This nee=
d to=20
be done for modern cards to use this infrastructure.

--nextPart2369908.xRTpSoHTD6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBNM4kqxdj7mhC6o0RAhaSAKCcJg6ZuVykVSGI2fEtL2dha4wiqwCeLMML
QneOrlNbTTtnHwlMW0XBAOo=
=nHag
-----END PGP SIGNATURE-----

--nextPart2369908.xRTpSoHTD6--
