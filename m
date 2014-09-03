From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V2 0/7] e1000: convert to
 build_skb/napi_gro_frags api
Date: Tue, 02 Sep 2014 22:18:50 -0700
Message-ID: <1409721530.2384.28.camel@jtkirshe-mobl>
References: <1409660690-10391-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4165903216942839789=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1409660690-10391-1-git-send-email-fw@strlen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4165903216942839789==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7yEkqUsewK4k8LBCOGRC"


--=-7yEkqUsewK4k8LBCOGRC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-09-02 at 14:24 +0200, Florian Westphal wrote:
> Changes since v1:
>  - in last patch, remove unneeded parens and casts,
>  pointed out by Sergei Shtylyov.
>=20
> v1 cover letter:
>=20
> e1000 driver preallocates skbs, then sends them up the stack.
>=20
> This patch series changes the rx routine to only preallocate
> packet buffers, then allocate the skb right before sending the
> packet up the stack.
>=20
> This gives slight performance inprovements as the skb will be
> fresh in the cache once its allocated/initialized.
>=20
> The default-mtu 1500 path is converted to
> build_skb()/netdev_alloc_frag.
>=20
> Jumbo path is converted to napi_gro_frags.
>=20
> Note that this has only been tested with
> kvms e1000 emulation.

Thanks Florian, I have added this series to my queue.

--=-7yEkqUsewK4k8LBCOGRC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUBqS6AAoJEOVv75VaS+3OwfYP/Rp1t1L7nLWDQMRdG+e1TChT
J6yC+2abGg0FIH7AVXHPDtNx5iTHTYocSgkTjeLsBAoQpXQtmZp/lMIpyxY36Le2
FSiZxbwQSRBLvZb4PgANsbqM1g8jnu7iuDOejNef23eL9hpWuZTy8yTgp4iKnm7N
hZHHmc6ypAw3MklyZz8++o7ronv+AwjgdsSWEc/iO4ieWijulycXY/YdveLA8Uu7
9sfuEjtY/EMPBioGFI6m2tviEJ/keujMMWqnKSc9xG0a3Ecm46Zs1it/UOcON98T
pFJQWBcNkpT7mn3ksm+7/MG7xtnF13abYXmgYFDT1ueEOCe7JzE/EuX4q6iuMPDw
3bJDienJkcvAKK45sDfO5qZXi6YkouhwerfBgZdVaeRULpV2vMTswPFBwQLxiXax
NlGLXQESwA1T25s+UEGLF8NyCg9GWDIdtZk+wLnsabFZBQ2mdzOOICTfdAilrCnB
aWcEGD7Qqse63zbDwA52TwlLnPtDGxF5MlnT606jI1Uq5WusoU7zfUqIWsK/GDvk
CLU9jQKJs9XxwTOj3HL2I89Wx/TYL6OIGsdUN37YFVBde24Mc2e9GGo+dqw6KOV1
2eJvouWRkR+johFXVmJbNlmC72YK42kJ7yeKjz+KyCMcxlseMrhqiCZ/iEaOJMbo
ICyvVptYR1jeBlCqyYKe
=IFEJ
-----END PGP SIGNATURE-----

--=-7yEkqUsewK4k8LBCOGRC--



--===============4165903216942839789==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
--===============4165903216942839789==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4165903216942839789==--
