From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier (fwd)
Date: Fri, 31 Mar 2017 23:19:35 +0200
Message-ID: <b1d77fbd-6a1d-4016-a823-ec986995012b@digikod.net>
References: <alpine.DEB.2.20.1703291712590.2989@hadrien>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="0tVLXNEI92e7PvWIT4vxfaEBh0tcpdoSv"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale
 <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-hardening-return-7217-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <alpine.DEB.2.20.1703291712590.2989@hadrien>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0tVLXNEI92e7PvWIT4vxfaEBh0tcpdoSv
Content-Type: multipart/mixed; boundary="p3fru9CKxWkAjcsTLnO5d6N5aad6JIRJt";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
 Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, kbuild-all@01.org
Message-ID: <b1d77fbd-6a1d-4016-a823-ec986995012b@digikod.net>
Subject: Re: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype and
 is_valid_subtype() verifier (fwd)
References: <alpine.DEB.2.20.1703291712590.2989@hadrien>
In-Reply-To: <alpine.DEB.2.20.1703291712590.2989@hadrien>

--p3fru9CKxWkAjcsTLnO5d6N5aad6JIRJt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Good catch, thanks again Julia!

 Micka=EBl

On 29/03/2017 17:14, Julia Lawall wrote:
> Size is unsigned, so not negative.
>=20
> julia
>=20
> ---------- Forwarded message ----------
> Date: Wed, 29 Mar 2017 23:06:01 +0800
> From: kbuild test robot <fengguang.wu@intel.com>
> To: kbuild@01.org
> Cc: Julia Lawall <julia.lawall@lip6.fr>
> Subject: Re: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype an=
d
>     is_valid_subtype() verifier
>=20
> In-Reply-To: <20170328234650.19695-2-mic@digikod.net>
> TO: "Micka=EBl Sala=FCn" <mic@digikod.net>
>=20
> Hi Micka=EBl,
>=20
> [auto build test WARNING on net-next/master]
>=20
> url:    https://github.com/0day-ci/linux/commits/Micka-l-Sala-n/Landloc=
k-LSM-Toward-unprivileged-sandboxing/20170329-211258
> :::::: branch date: 2 hours ago
> :::::: commit date: 2 hours ago
>=20
>>> kernel/bpf/syscall.c:1041:5-9: WARNING: Unsigned expression compared =
with zero: size < 0
>=20
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout 07d282aef4f60235407284c0be81d01e352e040b
> vim +1041 kernel/bpf/syscall.c
>=20
> f4324551 Daniel Mack        2016-11-23  1025  		return -EINVAL;
> f4324551 Daniel Mack        2016-11-23  1026  	}
> f4324551 Daniel Mack        2016-11-23  1027
> 7f677633 Alexei Starovoitov 2017-02-10  1028  	return ret;
> f4324551 Daniel Mack        2016-11-23  1029  }
> f4324551 Daniel Mack        2016-11-23  1030  #endif /* CONFIG_CGROUP_B=
PF */
> f4324551 Daniel Mack        2016-11-23  1031
> 99c55f7d Alexei Starovoitov 2014-09-26  1032  SYSCALL_DEFINE3(bpf, int,=
 cmd, union bpf_attr __user *, uattr, unsigned int, size)
> 99c55f7d Alexei Starovoitov 2014-09-26  1033  {
> 99c55f7d Alexei Starovoitov 2014-09-26  1034  	union bpf_attr attr =3D =
{};
> 99c55f7d Alexei Starovoitov 2014-09-26  1035  	int err;
> 99c55f7d Alexei Starovoitov 2014-09-26  1036
> 1be7f75d Alexei Starovoitov 2015-10-07  1037  	if (!capable(CAP_SYS_ADM=
IN) && sysctl_unprivileged_bpf_disabled)
> 99c55f7d Alexei Starovoitov 2014-09-26  1038  		return -EPERM;
> 99c55f7d Alexei Starovoitov 2014-09-26  1039
> 07d282ae Micka=EBl Sala=FCn     2017-03-29  1040  	size =3D check_user_=
buf((void __user *)uattr, size, sizeof(attr));
> 07d282ae Micka=EBl Sala=FCn     2017-03-29 @1041  	if (size < 0)
> 07d282ae Micka=EBl Sala=FCn     2017-03-29  1042  		return size;
> 99c55f7d Alexei Starovoitov 2014-09-26  1043
> 99c55f7d Alexei Starovoitov 2014-09-26  1044  	/* copy attributes from =
user space, may be less than sizeof(bpf_attr) */
> 99c55f7d Alexei Starovoitov 2014-09-26  1045  	if (copy_from_user(&attr=
, uattr, size) !=3D 0)
> 99c55f7d Alexei Starovoitov 2014-09-26  1046  		return -EFAULT;
> 99c55f7d Alexei Starovoitov 2014-09-26  1047
> 99c55f7d Alexei Starovoitov 2014-09-26  1048  	switch (cmd) {
> 99c55f7d Alexei Starovoitov 2014-09-26  1049  	case BPF_MAP_CREATE:
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source Technology =
Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpo=
ration
>=20


--p3fru9CKxWkAjcsTLnO5d6N5aad6JIRJt--

--0tVLXNEI92e7PvWIT4vxfaEBh0tcpdoSv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAljex+cACgkQIt7+33O9
apVZqggAgu5ylEt22VgNP+4RCV3v3jXAGvFvXBtzIMaUJ/rYxE1lewcayS6pNrnP
kKHLfWDe/Kam6fmhNNZAnMxt+PRhzAsSOfcQ8L3ztCE2OhS7Ep0suBf9yKC8imSD
O1VVRm7zdn4zVdebs0akpylTdi16f0PfGDXXNrTCpp+ZKiTOjJKh0aYe59ZDUGPL
PDeMQuG7Vjparqcnz3ksUBeveTNaB1B++LuBitRGo4KBWootW/++TBwV0vjScxSa
RBMZnFnzi9U8M5gKsv6NSiYDSaRlPiiEtallJsWztOacJTHTXDaPXc002wnncwMM
D/JTROnn18BPJRk394VGcEV9VNwLfw==
=MoLR
-----END PGP SIGNATURE-----

--0tVLXNEI92e7PvWIT4vxfaEBh0tcpdoSv--
