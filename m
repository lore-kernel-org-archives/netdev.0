From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] batman-adv: Revert "use core MTU range
	checking in misc drivers"
Date: Sun, 23 Oct 2016 09:17:50 +0200
Message-ID: <2358358.cV5hCSMD7y@sven-edge>
References: <20161022074624.30033-1-sven@narfation.org>
 <20161023010826.GD32569@redhat.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2805415.6Z7vPSiFGp";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161023010826.GD32569-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart2805415.6Z7vPSiFGp
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Samstag, 22. Oktober 2016 21:08:26 CEST Jarod Wilson wrote:
[...]
> You're going to
> need more than just this revert though, since batman-adv calls
> ether_setup, which will set min_mtu = 68, max_mtu = 1500, unless
> batadv_hardif_min_mtu() always returns something 1500 or less.

It does only returns 1500 or less at the moment.

    return min_t(int, min_mtu - batadv_max_header_len(), ETH_DATA_LEN);

> Actually,
> looking at that, you could omit the mtu < 68 bit from
> batadv_interface_change_mtu() too, since that'll already get done in the
> core, but I have no clue what you need for max_mtu.

I would like to get this revert through net-next.git before anything else.

Kind regards,
	Sven
--nextPart2805415.6Z7vPSiFGp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYDGQeAAoJEF2HCgfBJntGuVIQAIzsbzEegMhBUWxVyUQSaa/9
2hrcGTEvAZIkpONvw0b88RAO2OYKRvpI8SgPHCZ49DoGrorE1+Gt9vfSApIWaxrD
OMydAEtHzDjAGIxIu5ht2/vS4TzCWhun6lUzZDP+qGCSw1GDRcDQ1VSwhhj2D+TL
pwPRF655f78nWQAsO5sXBHakOHzdg+Vqvem1Mpn9Q6or7Svzurtxqm4ZglHpyLTZ
uRcpcl9FjFlGkyBn3LSXxhDBoU/UcwlYCFt5hDy616eFJVMsmVaVU3QXQqM/PbTa
jCoEjzYyIRE1XAplf86pe+B2QZiIg1/zRs7uCISNTDZ9eRh3yO2bjOuHOjhE/8Br
whEXr4ZZbLvO8OgtJaKMqRcx6BRx9tYXGork2vg3ILUfdOa8ivQEFVVZpW2ZObaq
LV0f8SmbPtI90pcKM2EH34Z3XhGM4xEBBK3VN/n2Z6ZjOKZaZoearaW+Bm7m9DyO
owpAcgMI/oxkaJPVkBMkBwe5QIGFRJKn3TWeSVYRIUU2gdHBlXwZMWbypaNqsQ/I
diWyp+c6yiyKqIUOIssiGA9WQeJPzaXnn0Q6pLJWmKxadW4yHmyAoKUKJVhD0+6K
Iz40mBAizFdGB7UhF582veriMzsNtWNWFRjHzknbCx+FuF5AO0TXIivjryxVTHKG
i+yjQyWLdO8iKiKAP9zb
=kdmv
-----END PGP SIGNATURE-----

--nextPart2805415.6Z7vPSiFGp--
