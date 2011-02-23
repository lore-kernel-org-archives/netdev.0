From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Re: Bug#614622: linux-image-2.6.37-1-686: atl2 NIC claims NO CARRIER
 after suspend/resume; rmmod+insmod fixes the problem
Date: Tue, 22 Feb 2011 20:57:55 -0500
Message-ID: <4D6469A3.50401@fifthhorseman.net>
References: <20110222180821.5217.2375.reportbug@localhost.localdomain> <1298423651.2211.496.camel@localhost> <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A48@SHEXMB-01.global.atheros.com> <4D64643C.1020001@fifthhorseman.net> <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A63@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigFC0436805F8766599A99F67D"
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"614622@bugs.debian.org" <614622@bugs.debian.org>,
	Cloud Ren <Cloud.Ren@Atheros.com>,
	netdev <netdev@vger.kernel.org>
To: Xiong Huang <Xiong.Huang@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from che.mayfirst.org ([209.234.253.108]:55271 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708Ab1BWB6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 20:58:03 -0500
In-Reply-To: <0FBC7C9C2640634A8B837C2EFFCFF32F01837E4A63@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFC0436805F8766599A99F67D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Xiong--

On 02/22/2011 08:38 PM, Xiong Huang wrote:
>    What I mean is to check if the cable link (you can check the peer li=
nk LED if your onboard NIC haven't) is ON.
> If the cable link is ON, we may focus on software layer :)

the peer (mini-switch) link LED stays off, regardless of unplug/replug
of the cable, power-cycling the mini-switch, or of tweaking the
interface via:

 ip link set eth0 down
 ip link set eth0 up

However, the peer link LED turns on immediately when i do:

 modprobe -v -r atl2
 modprobe -v atl2

hope this is useful info,

	--dkg




--------------enigFC0436805F8766599A99F67D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQJ8BAEBCgBmBQJNZGmjXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznpohwP/3pREEkQsJSU0ikOVN0Enp7z
56xCPpBXYYH1SOfpjG57FXFPOijLFe+WCavZzWZOpIrS0uUlejwg8sDdlxJrKHrf
4oRGGw6p5zNnGT9sNg2rw7p/dAB9tPP2ws3k1cWjkDzmxOMS5WTEYY0LluAdmGY7
dnpTVuxkQkHKiWSPecLSUwoOhr2dQ4jk5zHIzLTN1gMLJ/t2YEdvzDlYWFlidkO9
RuswK4+TBDvFea8UZHvy89Gt/ttdFWc+DQVxFJUSkxqUdIzv1fxOJrmOTQA1S4Cf
7M2fxMqDM4wuxZaQl+d9ujJmRRaI0fdA6Jy0YvFkYkUXzNp/Cq1EkJphL7v0ITP7
d1oTXSOZ1gjysBt+2Cyr9/luzFKl/0clFlIxCX2NwNq0iEelgoz2iMrnir3vP6iv
1I6vze1UpMFMBzIcqRtgBqtSSBHEP01nplk4zJ1W1C9gRNU2ZwEaccie3CiiGoNu
vtNqZbnUj2YBtNpunDBPAovYhb8RY2t6AmyV/RthWrJDK+wieS7iaoF+uu+zvzWV
rPJbGQBtTWVSpI+h3gDwjkaZphynvVLYat6k92Y2Zb03XnEEGpZO2e+BraZQLGvy
jgQ3rkaK+YW8JUu1HELixHZiMye9SBxMQKOFSmTF5r9gT4+K4OaD0Edbf9TFsbbq
y/L7cFpXKFg/AIjSCL40
=PMJY
-----END PGP SIGNATURE-----

--------------enigFC0436805F8766599A99F67D--
