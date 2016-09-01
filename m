From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Thu, 1 Sep 2016 10:15:02 -0700
Message-ID: <20160901101502.3ecaf21f@xeon-e3>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
        <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
        <20160831101028.7ea13fb4@xeon-e3>
        <57C82C3A.6090409@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ZTEnUW/kd2Cp5N3Bj8yhfih"; protocol="application/pgp-signature"
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35105 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753617AbcIAVNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:13:10 -0400
Received: by mail-pf0-f170.google.com with SMTP id x72so35005006pfd.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:13:09 -0700 (PDT)
In-Reply-To: <57C82C3A.6090409@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/ZTEnUW/kd2Cp5N3Bj8yhfih
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 1 Sep 2016 15:25:14 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> On 08/31/2016 07:10 PM, Stephen Hemminger wrote:
> > Since these are for control operations why a mutex? =20
>=20
> I am not sure to understand the question. The spinlock is used on the
> RCU write side of the namespace-wide parameters to prevent concurrent
> writes.
>=20
> David
>=20

If this lock is only being acquired in user context, then use a mutex
instead.

--Sig_/ZTEnUW/kd2Cp5N3Bj8yhfih
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXyGIWAAoJEICnf2CVzeR+ME0P/RwJoC3J5S5ZVXAF8TUm9RBV
0CAnG2XZSEyYsHpu+kVWlhJ3CzNVdBXQaLm3pRpaniWsd+pQDXNvyqIk1nmPn5Us
4ewDBcuCPt06VvbYG6LZA2W4/QDdMVzzNTGO0XJLQFA5Ow0KSTkmS3FFCrCD+KZD
qDS7rxPn3J8s13j2+aR/Bjf8qlAJBtZSIGVnB5xcQsFH6KBkB43g/R3VE+OtPnW+
QAtt6a7XCtzM6OUIu+/P2ukAeZqflK1Va0v4eLEEW2UrGVSGJIi/MLjjeb72S8/y
AySkwQiB8pVqQHF4dlVwCaUq4Op6DgbI+8frxR+DalMaUXQhfDcqqjeHxy8DtJV0
mYOIaJA5Qh6U9ZcNlNM3I3kpMrV683MKOOTJ176KGBhmb8kadpSQ333t6kTY02+k
aHyo7Ip7kn6UZdMqIk89Zjj7C58cniE2ukicebDKkcHVrsTQBUqcEGDlqaZeKbTt
gn+TDpGD+l0xYDopeddG9XypWLmbUa7IfUcf9vzrTZ+mmPN+TwWjQlQAbd7PDw+o
Ei/a/utbPQqANNdfVeqoONaHs6fWUdSlw5UHabyElK686AqL0ajibsAOfgqg6mhg
hs2N/n/TZ6OOLOyCwgTM0iYpcjSYXRyv5RIG6JqU7Ytx+B7r/K0iPzTdvcpmnSzo
Ls0X5M2YvIYs0FVo0ivb
=lsxn
-----END PGP SIGNATURE-----

--Sig_/ZTEnUW/kd2Cp5N3Bj8yhfih--
