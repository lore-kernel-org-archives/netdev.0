From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 11:47:05 +1100
Message-ID: <20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__2_Mar_2012_11_47_05_+1100_h/abhqDuE1mACIqp"
Cc: akpm@linux-foundation.org, Will Drewry <wad@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301233712.GS3990@outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__2_Mar_2012_11_47_05_+1100_h/abhqDuE1mACIqp
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kees,

On Thu, 1 Mar 2012 15:37:12 -0800 Kees Cook <keescook@chromium.org> wrote:
>
> Is it time to pull this into -next so more people can feel it? I brought
> Andy Lutomirski's patches forward (needed to bump the prctl values), and
> updated my git tree. If we're ready, here it is in all its request-pull
> format glory:
>=20
> The following changes since commit 2422c8368337196594265d52cad7316c9404bf=
cf:
>   Stephen Rothwell (1):
>         Add linux-next specific files for 20120301

OK, not commenting on anything else, but I cannot merge that into
linux-next because it is based on yesterday's linux-next release and
linux-next (effectively) rebases every day ...

Does this work depend on anything in linux-next?  Or could it be just
based off Linus' tree.  If it depends on other tree(s) merged into
linux-next, then you should base your tree on those tree(s) as long as
they never get rebased ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__2_Mar_2012_11_47_05_+1100_h/abhqDuE1mACIqp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPUBiJAAoJEECxmPOUX5FEQUEQAKRncHlwgk6v47bUivEe7B48
1D7ret2vYLOkiGY6oVmeT3B9xhAd7Q/Ig3EUBBGhn7Ar8tGoJP3Ih/ALWaQRI2Po
+bf//JgYAGagTs8yzyejWc02qFn+pD6nqYKpKsNr/RUz5CS/cdxHRcPIsd86Le6H
2xmRpMlWexE0Og374u9d/GqTomnhB3c5LVKgQQjpvqDfnDtpiPHxsoNlelE7ptb1
JHuVqrt7VylupGE5gOoUbnfV3x1oNHBEURvSn9lca3BwE8rFc323igdC06LDZ0/3
UkpqcGe7xfoWLsAzHLUgXCPt/wKYi/H43Z55GqQQBynOOhSM/kB4ONwi2Qcy1P/m
exCmuklvaA+RdNyZAejkHmXzQreNtJg8avu7cwSkLGXmczatgA57T8iI8OH1ystN
JM3jqKKa3Ca1l+c7n05Kv6aSHHXpyYyZftJOw1vmKzjlUwNCSjRLcmiK8sKw8/jQ
uoNAbz0RmUTTC8ae+DOzQ3QdLk+x2EtAeLLZV15V4XJfd4jVOIObxC+weyOQiHqE
7htsKNuntKhtr6INNpCL20Yp2v4otUGLD6xidvo3RqK7IoPvK1N/W59XQtK3ph0j
sYdn2p7sKVwxygoDr7iklFjPG08wTff7gIE0NAg2vfCMUoN3ByS8UlBs1py8LV9m
E0jd4rl2nsVzPwISWo/+
=VW2P
-----END PGP SIGNATURE-----

--Signature=_Fri__2_Mar_2012_11_47_05_+1100_h/abhqDuE1mACIqp--
