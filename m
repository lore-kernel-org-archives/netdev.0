From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the limits tree with the net and
 fsnotify trees
Date: Sat, 5 Dec 2009 15:00:53 +1100
Message-ID: <20091205150053.48384393.sfr@canb.auug.org.au>
References: <20091204183011.e92d36cd.sfr@canb.auug.org.au>
	<4B18C15A.8060901@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__5_Dec_2009_15_00_53_+1100_rI1moyQ8.mT_Eiyt"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Paris <eparis@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757689AbZLEEAy@vger.kernel.org>
In-Reply-To: <4B18C15A.8060901@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__5_Dec_2009_15_00_53_+1100_rI1moyQ8.mT_Eiyt
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

On Fri, 04 Dec 2009 08:59:22 +0100 Jiri Slaby <jirislaby@gmail.com> wrote:
>
> On 12/04/2009 08:30 AM, Stephen Rothwell wrote:
> > diff --cc arch/x86/ia32/ia32entry.S
> > index da89ae1,c61ced2..0000000
> > --- a/arch/x86/ia32/ia32entry.S
> > +++ b/arch/x86/ia32/ia32entry.S
> > @@@ -841,7 -841,6 +841,9 @@@ ia32_sys_call_table
> >   	.quad compat_sys_pwritev
> >   	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
> >   	.quad sys_perf_event_open
> >  +	.quad compat_sys_recvmmsg
> >  +	.quad sys_fanotify_init
> >  +	.quad sys32_fanotify_mark
> > + 	.quad compat_sys_getprlimit
>=20
> Thanks, but please go on with the by-five numbering in comments.

I am sure that will be done by whoever does the final conflict
resolution.  Thanks for noticing.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__5_Dec_2009_15_00_53_+1100_rI1moyQ8.mT_Eiyt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksZ2vUACgkQjjKRsyhoI8yi7QCeMKBHQDL69sdz8UaFNqoxf0ti
L0QAoK5cI+beDUwybAIAfr3VwHuzybjj
=Ir60
-----END PGP SIGNATURE-----

--Signature=_Sat__5_Dec_2009_15_00_53_+1100_rI1moyQ8.mT_Eiyt--
