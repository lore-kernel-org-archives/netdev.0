From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fwd: Question about kernel and IPv6...
Date: Wed, 23 Oct 2002 11:09:16 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210231108390.27212-100000@netcore.fi>
References: <1035360350.3db6585e0bdce@webmail.debianlinux.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: michael@albog.dk
In-Reply-To: <1035360350.3db6585e0bdce@webmail.debianlinux.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please try using 2000::/3 route instead of "default" route and see if tha=
t=20
helps.

You could also try to ensure you've enabled IPv6 forwarding.

On Wed, 23 Oct 2002 michael@albog.dk wrote:

> Alan Cox have recommended my to forward my questions to you, hope you w=
ill help=20
> me!
>=20
> Read the following:
>=20
> ----- Videresendt meddelelse fra michael@albog.dk -----
>     Dato: Wed, 23 Oct 2002 09:42:51 +0200
>     Fra: michael@albog.dk
> Reply-To: michael@albog.dk
>  Emne: Question about kernel and IPv6...
>       Til: Alan Cox <alan@redhat.com>
>=20
> To Alan Cox!
>=20
> Hi Alan,
>=20
> I am working on a master thesis called =93Internet Protocol version 6=94.
>=20
> In the project I have to setup a test-network for analyzing the RIPng p=
rotocol=20
> etc. I am using four normal Intel PC=92s each running Debian Linux, wit=
h a custom=20
> compiled kernel 2.4.19 downloaded from www.kernel.org. Two of the PC=92=
s are=20
> running as a software-based router (using Zebra 0.92a-6), and the other=
 is=20
> separately working as a client and server, respectively connect to rout=
er1 and=20
> router2.
>=20
> My problem is when I try to send an ICMPv6 request via the WAN-link (ro=
uter1=20
> and router2) from the client, I not getting any response from server. T=
he=20
> problem only appears when I try making a connection via the WAN-link, a=
nd not=20
> from router1<->server and router2<->client.
>=20
> My question is:
>=20
> - Could a problem be due to a wrong kernel-configuration? (I can attach=
=20
> the .config if you are interested).
>=20
> - What "kernel mechanism" is responsible for routing/transporting data =
between=20
> two interfaces? (I think that=92s the problem in router1 and router2. Z=
ebra is=20
> only exchanging the "IPv6 kernel routing information" between router1 a=
nd=20
> router2, and it is working fine).
>=20
> - What kernel version have most IPv6 features build-in ?? (Maybe a feat=
ure is=20
> missing in 2.4.19. I have read an article about patching the kernel:=20
> http://project6.ferrara.linux.it/papers/best_ipv6_support_4_linux/best_=
ipv6_supp
> ort_4_linux.html, it is necessary?).
>=20
> I hope you understand what my main problem is =96 English is not my pri=
mary=20
> language.
>=20
> I have got many information from mailinglists, messagesboards and homep=
ages,=20
> but the main problem is, that those information is conflicting. That=92=
s why I=20
> writing to the Linux Guru him self.=20
>=20
> Btw. You are doing a very good job with the Linux kernel!
>=20
> Best regards,
>=20
> Michael Olsen
>=20
> Atkins Danmark A/S, Tele=20
> Pilestr=E6de 58
> DK-1112 K=F8benhavn K
> Telefon: +45 8233 9154
> Fax:     +45 8233 9017
>=20
> ----- Slut af videresendt meddelelse -----
>=20
>=20

--=20
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
