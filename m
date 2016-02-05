From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/2] ethtool: add IPv6 to the NFC API
Date: Fri, 05 Feb 2016 01:32:52 +0000
Message-ID: <1454635972.20702.8.camel@decadent.org.uk>
References: <56B0F9A8.7010202@solarflare.com>
	 <56B0FA25.8030708@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JFvffVqyt6D7ZZ5EfjBs"
Cc: netdev@vger.kernel.org,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35467 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbcBEBdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 20:33:06 -0500
In-Reply-To: <56B0FA25.8030708@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JFvffVqyt6D7ZZ5EfjBs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-02 at 18:49 +0000, Edward Cree wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> =C2=A0include/uapi/linux/ethtool.h | 70 +++++++++++++++++++++++++++++++++=
+++++++----
> =C2=A01 file changed, 64 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 57fa390..3b6af3e 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -748,6 +748,56 @@ struct ethtool_usrip4_spec {
> =C2=A0	__u8=C2=A0=C2=A0=C2=A0=C2=A0proto;
> =C2=A0};
> =C2=A0
> +/**
> + * struct ethtool_tcpip6_spec - flow specification for TCP/IPv6 etc.
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @psrc: Source port
> + * @pdst: Destination port
> + * @tos: Type-of-service
> + *
> + * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
> + */
> +struct ethtool_tcpip6_spec {
> +	__be32	ip6src[4];
> +	__be32	ip6dst[4];
> +	__be16	psrc;
> +	__be16	pdst;
> +	__u8=C2=A0=C2=A0=C2=A0=C2=A0tos;
[...]

IPv6 has 'Traffic Class' instead of 'Type of Service'. =C2=A0At least the
kernel-doc comments should use the proper name, and perhaps you should
rename the 'tos' fields to something like 'tclass'. =C2=A0(Definitely not
just 'class' as UAPI headers have to be C++ compatible.)

Ben.

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein
--=-JFvffVqyt6D7ZZ5EfjBs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVrP7xOe/yOyVhhEJAQrSQhAAvIU1qJhOoRDTHMMba7wLtI7UgvIG6qBY
31sUoe8R7qSg5md2wFScv6W+ZiWXc8SQhOYf9M3iSVOToLUXy1T5eLGBi7krFKCF
kNOSNRQ8ZpOfRY3yWh1kpry14idf3qkgBhjJqTiTzqRhw2VmrL3bWiGqUa8Iw4HK
aj2iTix61d9inHM57ziMeUxfagUCeQiKnkWF/5Zv50Gbe+RYy/Mg/OOWVsvE+B1r
2aI5WZO/aW5nJqsZzS1BpNVlu/IrBvEmjI6Yb+vyMaRQl8BZiwQyIZkfExKCBzzZ
CHe6zqLq1LHkC+bqlfYyPhCWqMbU1V6ptuY7vR9U2BPOhyuPqX0LhYkeRlFmedXD
p4qob6Ix/SV5H3cz7tezead2bPyBYoVlx8OhxKJQInIZ6Z4g4EnSJJXHfxHF1wjI
iChFy4sBeahgZKUjqfjYyIB6ImQOnNyIFL6JDj0+2NbJcPLYBxRhyotWeBUZL0SH
Vzj+eaB1ZjLg2+NSO+otMYgqlo5kJtjiPlbF8nCKYIQ/qxxbFdheqYnD1bdZBe/c
cRbiFFwvNdwj//lGov1k9RLvd3mmn5235bUeBKt7ro/YUdcx+XPLR7F8aA9eQGyc
6fWxVgQkeVEwFbyRy+6lK6OG3Xl1bvhs5q4+sAiMvTFa/D/HPj9484ph7Iy+Kfq+
d4E9MGnSgt4=
=Cu0k
-----END PGP SIGNATURE-----

--=-JFvffVqyt6D7ZZ5EfjBs--
