From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: d80211: clean up some list and loop code
Date: Fri, 17 Nov 2006 00:37:40 +0100
Message-ID: <1163720260.3392.24.camel@johannes.berg>
References: <1163718270.3392.19.camel@johannes.berg>
	 <20061116232455.GA3297@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Top+hRrkNuqAXiAsOR41"
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21963 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1162320AbWKPXjP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 18:39:15 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061116232455.GA3297@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Top+hRrkNuqAXiAsOR41
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Ever heard of while loops?

was more about

> "for (; condition ;)".

:)


> FWIW, I think I prefer the "for (;;)" version for endless loops.
> It looks more intentional to me.  Some grep'ing showed nearly equal
> usage of "for (;;)" versus "while (1)".  Is there any "official"
> preference?  I don't see anything in CodingStyle about it.

I think while (1) looks more intentional, but I suppose that's because I
grew up with pascal where you can't do all these weird things with for
loops.

Feel free to drop this part of the patch if you wish, or, if you want, I
can resend without that too :)

johannes

--=-Top+hRrkNuqAXiAsOR41
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVz2QqVg1VMiehFYAQLRIg/8DbBS80Cq/Ta+yMpTtqCwLLcL3z1So1M/
BYm6NcvdMUzxTn/xi+dh0J9pd39Lr0UcVg4IixQcHKrLs0FubURozPQfcVJToDx1
9G3euNZ7E9HY+IW2WF6G09kkhqmtxqje+uM5L195y5rDn4jtlsV9Gox0OJ0w+/1C
INUIrwzLXmvAFUqeFKO+6tpm2htM2bbSi6o7zvUsxSKrhabN1dkEE9wWfMvr8FPs
GzS+0JXP8neZtW/aF5THoKfM/BJm+grOvigVF3EAhyfXoZjMI03puihEtLN5JWY0
qfJVzM4Z0PZ1jMWlYFrOlStN+akiPw7iP5WFbwBlNC6NI9bQG4mlj97YdwUQEvXZ
nmORs8L3q+M2EbvXeKIS/c/I7NNF7TSz7PbkdntlVnjAhKbcPm4pS52Dv7eupo1k
FeXl5kktO/h7TafjXjB44hPjcT0UYkXiNj8DI89dpAO9eZXafjxiYnMficzthv+C
KdpTcgKRzXQpiPDy3oMM39TJqRnD6YDGOtoHD/xZZg/0Q2YbEEQCjo9gOPGNw8eU
kg+Z3WF16fYny8X1U3TgIbPkngCxSRwEMji+MiVF1KXaUfycC7MtiD08KDoGNAnc
FDYWJPCknrT1Szrbur7VfEjj5S1Q7BscIZtiaNGotXE3QycEERFlP6O94YBwf/BI
OyApXOt+PDg=
=i8SD
-----END PGP SIGNATURE-----

--=-Top+hRrkNuqAXiAsOR41--

