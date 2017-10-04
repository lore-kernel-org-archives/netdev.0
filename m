From: Richard Siegfried <richard_siegfried@systemli.org>
Subject: Re: [PATCH net-next 3/3] Move shared tcp code to net/ipv4v6shared
Date: Wed, 4 Oct 2017 10:57:42 +0200
Message-ID: <1a77c067-7ab0-4e98-4456-fd6e9fab23b2@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003222213.7996-4-richard_siegfried@systemli.org>
 <CAOaVG14r2Uwm+r17Oa9jwKj50vRr8=SqwXEmmGAeW8rHj3FgXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="a8Cx4lo8CChtN3rQHRLpWuOoP62GkKwpR"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:36786 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdJDI6K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 04:58:10 -0400
In-Reply-To: <CAOaVG14r2Uwm+r17Oa9jwKj50vRr8=SqwXEmmGAeW8rHj3FgXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--a8Cx4lo8CChtN3rQHRLpWuOoP62GkKwpR
Content-Type: multipart/mixed; boundary="20QlCQTMARddI58BaOKRbfTw16VHMQuks";
 protected-headers="v1"
From: Richard Siegfried <richard_siegfried@systemli.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
 yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Message-ID: <1a77c067-7ab0-4e98-4456-fd6e9fab23b2@systemli.org>
Subject: Re: [PATCH net-next 3/3] Move shared tcp code to net/ipv4v6shared
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
 <20171003222213.7996-4-richard_siegfried@systemli.org>
 <CAOaVG14r2Uwm+r17Oa9jwKj50vRr8=SqwXEmmGAeW8rHj3FgXg@mail.gmail.com>
In-Reply-To: <CAOaVG14r2Uwm+r17Oa9jwKj50vRr8=SqwXEmmGAeW8rHj3FgXg@mail.gmail.com>

--20QlCQTMARddI58BaOKRbfTw16VHMQuks
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/10/17 03:32, Stephen Hemminger wrote:
> The name ipv4v6_shared is longer than it needs to be maybe ip or ip_com=
mon
Well ip_common sounds nice.

But I don't fully understand what this means for the current situation.
I could do a v2, but would that make any sense since Dave and Eric
already said "no" to the whole concept.

Would it change anything to keep the tcp directory in net/ipv4/ (only
1/3 and 2/3)?



--20QlCQTMARddI58BaOKRbfTw16VHMQuks--

--a8Cx4lo8CChtN3rQHRLpWuOoP62GkKwpR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQFTBAEBCgA9FiEEBgAhuYrOnl9UC7I39kE5zAWb4eEFAlnUooYfHHJpY2hhcmRf
c2llZ2ZyaWVkQHN5c3RlbWxpLm9yZwAKCRD2QTnMBZvh4W00CACWw/6zQ0MAYFzM
NNH7/JW6ZLnFr3WqVCUodKXQLBtOrU4NdvLxImfI2c+0Id/EObLxdT36aVNB+1eE
U9kKzO69MSoBjhnvOzdThYKROMbIpoL5D+2TuBS+803pkKD7zeZVph9RpXmibPYD
QCMJU5NxqFCdvUQGl1bcCzPnMrd1XzG7da7y6PjUOQdnGPtpAst50nysj0Df6fhR
IWjGhBGoimFbpKtN2bsac9zRLIFnCgwED9Z5qNx7MyYz9c1KOTF4E1+Pa6Lwc04A
xDQny1Y2MR21Ez/fWHLXxY2UB9tUSn8J9Nbp57INA12JBkfw7Q+ksrkPZjz3cRNe
DLTEGSOL
=HV4q
-----END PGP SIGNATURE-----

--a8Cx4lo8CChtN3rQHRLpWuOoP62GkKwpR--
