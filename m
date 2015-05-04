From: Ben Hutchings <ben@decadent.org.uk>
Subject: net: make skb_gso_segment error handling more robust
Date: Mon, 04 May 2015 23:38:55 +0100
Message-ID: <1430779135.4113.202.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9MJxbr1qEuS63Mcqvrcw"
Cc: netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Brad Spengler <spender@grsecurity.net>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9MJxbr1qEuS63Mcqvrcw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Brad Spengler pointed out this commit as a candidate for stable:

commit 330966e501ffe282d7184fde4518d5e0c24bc7f8
Author: Florian Westphal <fw@strlen.de>
Date:   Mon Oct 20 13:49:17 2014 +0200

    net: make skb_gso_segment error handling more robust

Some hunks need to be dropped for older branches as skb_gso_segment()
has gained more users over the last few years.

Ben.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.

--=-9MJxbr1qEuS63Mcqvrcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVUf1BOe/yOyVhhEJAQoE1xAAy8mMgAGB9vCUMbZt7E4EaChIN+kxnfz1
Who5XqCDc0TtDKCgQbTep2usrYRp7Be+SY/mGCYADfdxWTF8OcVTaerIoRHKwWBn
NSSmq3hoowVK4aUXHSBYDR1/h0icGbm4Yu+EBSWgg8ul7LTaakI62gV9PmBRiK5/
zZbFV/WsQ8JCQUbETlFTLpoOcdCftbvkYy6HKXrm3P0/fVwvHqUiMpe+AUmcfb16
05zGi5UhO/u1at1Tagqo2WeThyo/2o+/top3ZkJf5vMuZsvwYtInagwHxB6Mick0
ZMJJ5rBNqZ5o8Hmm0I47S0IZLjE4+AFkfWx9mmNMQPUZ+hjNn6+CHMjeOkOuEmcv
IC20cJWwNXAMqGNpZRMH34FOfoDXSt8r3JlCsO7XoS7EREaFaZFXzXbUdSrgvMaI
tvv4kD1G2b1fSBnsB0bBC9NZe970+SWxxAMPQwzoAnR8S1b23iP2IDUsjTg9gWud
QIl37OHnIPRzCi3bySwYeGHj3uyOuZ0x8B8NAL294KfRpCFFBXa2ut/fdBe4GTYJ
aQ4tpfTJ2oy90aVKYyTVv1J0FME8C+1YLuAU/Zffol5HeeMjxrFDWs6HENFPvjaH
76dQ6mgx38JJgZ4DMZjJUbuIwWFsfmAnLkaStlN3aVarxBFT1BSvdRWOX+NaVy+3
KBd3V8tl6aA=
=14E3
-----END PGP SIGNATURE-----

--=-9MJxbr1qEuS63Mcqvrcw--
