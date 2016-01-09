From: Robert Sander <r.sander@heinlein-support.de>
Subject: Re: Configure ICMP error source address
Date: Sat, 9 Jan 2016 17:41:54 +0100
Message-ID: <56913852.4030608@heinlein-support.de>
References: <568F8207.9040305@heinlein-support.de>
 <20160108152448.5251154.50977.21786@gmail.com>
 <568FDFBF.3010300@stressinduktion.org>
 <20160109035708.5251154.82433.21820@gmail.com>
 <5690D98B.7070003@stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="0fw2Arqall31MWXTXAxfSthDnW8iS5iq8"
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.heinlein-support.de ([91.198.250.30]:56299 "EHLO
	mx3.heinlein-support.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbcAIQmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 11:42:00 -0500
In-Reply-To: <5690D98B.7070003@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0fw2Arqall31MWXTXAxfSthDnW8iS5iq8
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,

Am 09.01.2016 um 10:57 schrieb Hannes Frederic Sowa:
>=20
> I would also use dummy interfaces in production systems, merely to spli=
t
> the statistics from dummy.

Thank you for discussing the merits of dummy interfaces. I will consider
your arguments. But unfortunately this did not answer my question.

Let me rephrase it:

Is it a good idea to set a specific global IPv4 address as source
address for outgoing ICMP error messages?

Would it be OK to create a /proc/sys/net/ipv4/icmp_errors_source where
you could write an arbitrary IPv4 address into? And that would get used
as the source address of ICMP errors?

My questions did contain the loopback interface as I first thought it a
good source of a globally routable IPv4 address (at least in our case).

Secound thought: Instead of writing an IPv4 address to
/proc/sys/net/ipv4/icmp_errors_source write an interface name to that
file and take the first global IPv4 address from that interface as
source for ICMP errors. Then you could create a dummy interface for that
use case, too.

Still: Is it a good idea to do so?

Regards
--=20
Robert Sander
Heinlein Support GmbH
Schwedter Str. 8/9b, 10119 Berlin

http://www.heinlein-support.de

Tel: 030 / 405051-43
Fax: 030 / 405051-19

Zwangsangaben lt. =C2=A735a GmbHG:
HRB 93818 B / Amtsgericht Berlin-Charlottenburg,
Gesch=C3=A4ftsf=C3=BChrer: Peer Heinlein -- Sitz: Berlin


--0fw2Arqall31MWXTXAxfSthDnW8iS5iq8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJWkThTAAoJEPC7kVgj3lsoUnEP/2XDtGzr9hEEgBt8c2vCu62y
TDbQsZOvF1bMwGdwMJqg1mkV7hfJGepD4iCjTmZsJiaPW6TkeqwzJ9iNF8qYQeqC
dcPU1ZhHORmR1rcKQcfM5DukvY2HLvkVXUkNbDJ1RagMS0AEPxQmRU87fwqqHp8G
Xg6H4atMBOL0aEeS0jhdztg1+XCKBX8dJPtGAp2piz+wKqKaQ5fZkorc/QPu106e
Akp0ulnuWXxQ3pFg3inSOIqDJDrVq6kOVe/cCfcY1DN0xwo3sNuu9+lhE/Nz6kzk
1NQsc+bGNRvdz1jmowICx5QWi1F6PsCsP8UMD8ToyZsxw8q+zfHJUAfRl63zzYQT
0pkpeDBwgq5bel6Cg57wL5a3Iy2DIDPFJhMtjZJ/4rMa/rhoplOUlGLuzjOPhDOn
PNLCWwgFjQC7iAkSGZbuN3XvGTlm6zQkVqAQu5/reaCRawnd1Qee2ACRTHlldI9b
UpJ7+GJ1nqfPMNSDbxZgylsRJyk1SWt8ecnTPYn62JU/hKwztzzluJ1ErobKbTNn
pCQXlZdETi5xEDyefq3FMMje8VT/H6zNtiQMdGB2xiK7dXAlbI8NKc1N1abjM52z
uYbdlJNs+4hoCy5TEH0KFBYX0tjfk2iJ4wmVcy3QmYogUEfeGa6OPkU2R2S7KTXL
sDhFeaeSeBhkSzvgVaXR
=FLnh
-----END PGP SIGNATURE-----

--0fw2Arqall31MWXTXAxfSthDnW8iS5iq8--
