From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: ibss.c backtrace when batman-adv adds wireless
	interface
Date: Wed, 03 Feb 2016 18:14:55 +0100
Message-ID: <5257267.1LZJPcyIcQ@bentobox>
References: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2329807.jhdNh6WYTb";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CA+5PVA4HVjsEw+j+HMDzO0gnQb4xTRwbAu4H2do3MU41QWvOvw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

--nextPart2329807.jhdNh6WYTb
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 03 February 2016 10:24:43 Josh Boyer wrote:
> Hi All,
> 
> We've had a user report the backtrace below when loading batman-adv on
> his machine.  It looks like the cfg80211 layer is complaining about a
> null bss returned, but I cannot tell if the rtlwifi driver or
> batman-adv is in error here.
> 
> Thoughts?

About the attachment "batman-adv oopses with kernel-4.3.4-300+debug". Sorry,
this was my fault and caused by an copy+paster error while adding some
lockdep_asserts. This caused too many lockdep reports. It was fixed a while
ago upstream in 008a37448707 ("batman-adv: Fix lockdep annotation of
batadv_tlv_container_remove").

Kind regards,
	Sven
--nextPart2329807.jhdNh6WYTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJWsjWPAAoJEF2HCgfBJntGXngP/1AnZSxN9oDkZmkDbanuHvdL
7JUaza7ghgK8Eofs6Hp5vIfJGTODpZeIQ7uvfZwj3/LWIxsil5PIrDSIfuwthJLA
FyU8JKLHezcZ0SPsK7oABtWREHdARTpe/EYngru6KWVpPTdK2Jscf1YEVGleqx7Q
UEHoKo09mYBrIL+9O+ekavLFC/O9PbsMuu2nF2W+0MKyXVB6TTE/4wF8ZBlS2BHp
VwFBilXmJAPtbs1Mo6M7gC9kCjoqWOHVT5S3ZHDqB839Y2XAiSLMJD28ck60n9zb
RbkxhQYwGGUxQ95OkGgzFtTbkG6NC3WWTckNUuoipn04ls7V2yJ9ZNIaxsQIcu3l
0w5M2ITBYF6Pvo2KUvOwy3xT+CNAXvzXh3ZeOQfMgYWfRP65qw5qjOxGc5DdFm+U
hOvmu6B01v27+vr9+KFEqjFUOYNgA4dY2fok6B8d3UmKmQwaDvuWk3880cO03Y5Z
spiIIqrutKpsziPnM98/F52E+aYssQuvBSHT5TatP1WWVOiCuOgHORJhejGCZHaN
4UmKYe00Eg1fAtemR33yHF+5VdJnohY2adAcMUU2dZ6uID39w60dIs1lb2DeEHdF
LRTWsnIYAJWv4UVOLEqMn1g+d/YuowgzmGrYUdvIPrydBlAeOJbEPmxdR15ZLdal
xBYGHhyjp43Vre/EiSVC
=66Fg
-----END PGP SIGNATURE-----

--nextPart2329807.jhdNh6WYTb--
