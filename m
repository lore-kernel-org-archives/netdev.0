From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 18:24:00 +0200
Message-ID: <351cfa76-3fba-ffd0-3deb-e65eadf88223@universe-factory.net>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
 <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="QrOOXc0samihLMTHDlnGIUxt6rlcNRjgJ"
Cc: Girish Moodalbail <girish.moodalbail@oracle.com>,
        pravin shelar <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:49310 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752724AbdHKQdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:33:40 -0400
In-Reply-To: <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QrOOXc0samihLMTHDlnGIUxt6rlcNRjgJ
Content-Type: multipart/mixed; boundary="7IqTCF5AwHqXbrrdXunfsuSrO4eDunNmh";
 protected-headers="v1"
From: Matthias Schiffer <mschiffer@universe-factory.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: Girish Moodalbail <girish.moodalbail@oracle.com>,
 pravin shelar <pshelar@ovn.org>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Jiri Benc <jbenc@redhat.com>
Message-ID: <351cfa76-3fba-ffd0-3deb-e65eadf88223@universe-factory.net>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
 <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>
In-Reply-To: <CAJieiUjYggf3zNzwBMFq7zUm+RrZokZ7oNpuz-Hinec=0OSGzA@mail.gmail.com>

--7IqTCF5AwHqXbrrdXunfsuSrO4eDunNmh
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 08/11/2017 06:19 PM, Roopa Prabhu wrote:
> On Thu, Aug 10, 2017 at 2:16 PM, Girish Moodalbail
> <girish.moodalbail@oracle.com> wrote:
>>
>>                 if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) =
{
>> -                       pr_debug("invalid all zero ethernet address\n"=
);
>> +                       NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
>> +                                           "Provided Ethernet address=
 is not unicast");
>>                         return -EADDRNOTAVAIL;
>=20
>=20
> keep it simple and closer to the original msg: "invalid all zero
> ethernet address"

It is inaccurate though, is_valid_ether_addr will also reject multicast
addresses.

Matthias


--7IqTCF5AwHqXbrrdXunfsuSrO4eDunNmh--

--QrOOXc0samihLMTHDlnGIUxt6rlcNRjgJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEZmTnvaa2aYgexS51Fu8/ZMsgHZwFAlmN2iAACgkQFu8/ZMsg
HZxkKBAAgYVcZR9ViTH/AWXmu2FexUYDVhWl8FH2hycKEtoAD8ZvhtI/1vehFxto
P1D1nCeFLOnqjED985Ecs7gaoOKzbPPKQvTHZ69OoCgAsAD1bPhpsqZjPGBMkuEx
i8jm5t0bSTAvmaA9oWzTEcWKSXwskZllhwEDYkKK48Px1BZ0kz5j5ULte1AZaCOt
nUcMkBzmyWnMZ+oE5PGbQ3VNu5FLsxf1OKBOVN3KPAR3tM7P5kcXljZc49IF4cF/
vwTfRaIhABHU1eOWN25CR1sX3A43bjK+W/VtAkmwD3HlN8AI+yAdSdgR2Y3A6BCu
oppeZS19n0qjqTNR0+syB3pSR0a21HjnKYB3FtUGJYVn0U8UESni9CHEi9wLg197
ZT2OL4nWXtyDHaxTAmSUWlUWc96Iniz6gWXuXWMJShFWDx8S0V/K8sO9JUfTCEzQ
X4xC07UUltd6usA4XII8bs48YRBy98sfc7GImoiL+x50RvKePwo1vPdVEAuMA0m5
pp0VREGx/ej3STdc/IkW+63+56gMdFsGQU2/uUfw8Ma6DMiKXiRjLcpEOJDJ6oF7
wQFt02s5yUJ0AG/N49VudNQH6OdTQRwZUXBIVgcfgq03O5NRruhrXGGJ5fuqK/be
gi1k4J97swErE62YDRGARnHPNst8QY2fXftakHAbpif5+qwwl+A=
=LXbc
-----END PGP SIGNATURE-----

--QrOOXc0samihLMTHDlnGIUxt6rlcNRjgJ--
