From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH v2 0/9] net: add support for IPv6 Segment Routing
Date: Wed, 26 Oct 2016 18:03:39 +0200
Message-ID: <5810D3DB.4040503@uclouvain.be>
References: <1477497292-22155-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="NFirG3jVTCnQmKv8E28X3vBmVbvEt0uPW"
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35896 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932188AbcJZQCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:02:05 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 086FF67DC40
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 18:01:56 +0200 (CEST)
In-Reply-To: <1477497292-22155-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--NFirG3jVTCnQmKv8E28X3vBmVbvEt0uPW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/26/2016 05:54 PM, David Lebrun wrote:
> struct ipv6_sr_hdr {
>         __u8    nexthdr;
>         __u8    hdrlen;
>         __u8    type;
>         __u8    segments_left;
>         __u8    first_segment;
>         __be16  flags;
>         __u8    reserved;
>=20
>         struct in6_addr segments[0];
> } __attribute__((packed));

I forgot to update the struct in the cover letter description, please
disregard. Actual struct is:

struct ipv6_sr_hdr {
        __u8    nexthdr;
        __u8    hdrlen;
        __u8    type;
        __u8    segments_left;
        __u8    first_segment;
        __u8    flag_1;
        __u8    flag_2;
        __u8    reserved;

        struct in6_addr segments[0];
};


--NFirG3jVTCnQmKv8E28X3vBmVbvEt0uPW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgQ09wACgkQjbzn67sZ6APQ/wCdF/yY5XC2bod1bciSSgVUlgxn
vUgAn0vrZJEMzhl1OWvcL0iwrxDNcSfY
=Xx2X
-----END PGP SIGNATURE-----

--NFirG3jVTCnQmKv8E28X3vBmVbvEt0uPW--
