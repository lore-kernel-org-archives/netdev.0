From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH/RFC v5] introduce HAVE_EFFICIENT_UNALIGNED_ACCESS
	Kconfig symbol
Date: Wed, 02 Apr 2008 12:24:25 +0200
Message-ID: <1207131865.10910.30.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
	 <1206038373.16475.150.camel@johannes.berg>
	 <20080320.141307.173590705.davem@davemloft.net>
	 <1206454302.16475.269.camel@johannes.berg>
	 (sfid-20080325_153049_310071_1A4FA1C2)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PzYZr5wvbvwi0Af8EbdI"
Cc: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1206454302.16475.269.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080325_153049_310071_1A4FA1C2)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-PzYZr5wvbvwi0Af8EbdI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Tue, 2008-03-25 at 15:11 +0100, Johannes Berg wrote:
> In many cases, especially in networking, it can be beneficial to
> know at compile time whether the architecture can do unaligned
> accesses efficiently. This patch introduces a new Kconfig symbol
> 	HAVE_EFFICIENT_UNALIGNED_ACCESS
> for that purpose and adds it to the powerpc and x86 architectures.
> Also add some documentation about alignment and networking, and
> especially one intended use of this symbol.

I haven't had comments on this last version, any objections to sending
it to akpm for inclusion? I would like to start building on it in the
wireless tree.

Also, what's the best way to get arch maintainers to note this and
evaluate whether they want to set the symbol or not?

johannes

--=-PzYZr5wvbvwi0Af8EbdI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR/Ne2KVg1VMiehFYAQJRsQ//QuaXGmGHrbnx6afUKwRP++DDNgZOinMi
ioJWGJaxw/O5jwCA52InBB5BGPN9D0ibzv/iNLM3SYmiIr+T2MJpnzX6ZAJlPuyU
5Pm8MkBxZoT34YzV+v86LUYozpy6VnxpYto7MGGYGdlfKyp8OdIupuQQP2eyDNoC
9hVJ6fdYEL+pMCd1hrnjR33S6ebDTtC4yzkqe3ojuGTfIuiq4DcgmJit4VWskl/S
Zz6oKBzd0G8SFh4T3Cz8gXX9r9OhhMgCH/YQvK+AbSYbhj/6ip+SXE0ID5+tAPzQ
BEqBp2rxrLzGjrjd95E+Ilb16tWymmmKtfJU97xuHgaLxAdINOnjPDj6yNDiVLgV
z9n6DrQ8+BWu2FVpbDQpnaccsOht2n/AlvXXdHgIQskeZ2fbZB8Sz6spX3SpUJ4i
BABy9CkC7PWktrxlO04j29YUwmBx2Xv0L/rj6+Ww7r5aQmagVSwu9qn0D+Y1TnDh
K0fFOfuLgnbwn2IkXrucnX1FHrVd1lN+l9ePO5ntDM9F0+tGVISL8SsxMJRfKN3Y
S/9gJGWF2EDRdoJCCmd/xe/3QLErdIEJnjSNyqCMF4s7l7nrqVMHhZE2iAUPeboa
advKajAdyEJHPhxcga+LiRGZdBX0cB7Ta4bSFADQgxIrrp3zA6nOaCnY17y6NXgN
RuH8RrnT3FA=
=rPxH
-----END PGP SIGNATURE-----

--=-PzYZr5wvbvwi0Af8EbdI--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
