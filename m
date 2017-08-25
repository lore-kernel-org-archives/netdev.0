From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 01/10] selftest: Enhance kselftest_harness.h
 with a step mechanism
Date: Fri, 25 Aug 2017 09:58:33 +0200
Message-ID: <0e15da13-fad0-ba01-053c-1b4853e2bd6f@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-2-mic@digikod.net>
 <20170824023105.gt6lyn2snhczryik@ast-mbp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="j9s9wGVNtit22hNfKuJ4gG5AXcFDrKD2s"
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
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Shuah Khan <shuah@kernel.org>
Return-path: <kernel-hardening-return-9558-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170824023105.gt6lyn2snhczryik@ast-mbp>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--j9s9wGVNtit22hNfKuJ4gG5AXcFDrKD2s
Content-Type: multipart/mixed; boundary="UeCjjMRncgOANfvqB1uxGuu9d3I3RnmWI";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Shuah Khan <shuah@kernel.org>
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
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
 linux-security-module@vger.kernel.org, netdev@vger.kernel.org
Message-ID: <0e15da13-fad0-ba01-053c-1b4853e2bd6f@digikod.net>
Subject: Re: [PATCH net-next v7 01/10] selftest: Enhance kselftest_harness.h
 with a step mechanism
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-2-mic@digikod.net>
 <20170824023105.gt6lyn2snhczryik@ast-mbp>
In-Reply-To: <20170824023105.gt6lyn2snhczryik@ast-mbp>

--UeCjjMRncgOANfvqB1uxGuu9d3I3RnmWI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 24/08/2017 04:31, Alexei Starovoitov wrote:
> On Mon, Aug 21, 2017 at 02:09:24AM +0200, Micka=EBl Sala=FCn wrote:
>> This step mechanism may be useful to return an information about the
>> error without being able to write to TH_LOG_STREAM.
>>
>> Set _metadata->no_print to true to print this counter.
>>
>> Signed-off-by: Micka=EBl Sala=FCn <mic@digikod.net>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Shuah Khan <shuah@kernel.org>
>> Cc: Will Drewry <wad@chromium.org>
>> Link: https://lkml.kernel.org/r/CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWy=
kZyrYiVPz3Y3Q@mail.gmail.com
>> ---
>>
>> This patch is intended to the kselftest tree:
>> https://lkml.kernel.org/r/20170806232337.4191-1-mic@digikod.net
>>
>> Changes since v6:
>> * add the step counter in assert/expect macros and use _metadata to
>>   enable the counter (suggested by Kees Cook)
>> ---
>>  tools/testing/selftests/kselftest_harness.h   | 31 ++++++++++++++++++=
++++-----
>>  tools/testing/selftests/seccomp/seccomp_bpf.c |  2 +-
>>  2 files changed, 27 insertions(+), 6 deletions(-)
>=20
> is there a dependency on this in patches 2+ ?
> if not, I would send this patch to selftests right away.
>=20
>=20

The Landlock tests [patch 9/10] rely on it for now.

I sent it three weeks ago:
https://lkml.kernel.org/r/20170806232337.4191-1-mic@digikod.net

Anyway, until this patch is merged in the kselftest tree and then
available to net-next, I'll have to keep it here.


--UeCjjMRncgOANfvqB1uxGuu9d3I3RnmWI--

--j9s9wGVNtit22hNfKuJ4gG5AXcFDrKD2s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmf2KkACgkQIt7+33O9
apXVFggAqku2EMT7+1wnMtNPleU3+pn6XVupJE8G2oG1ojSl69u5CtNK8G+Lp8Ge
aYpbQKXzhqjSVFnuava7HWIH6jmisTzKbkK19lgwMn6nWEY9qgVOdeGyG6HZD29c
zPsvNKfugvOxruC7MrbXm/iz+Jj+vhOodBvFVSwFh1GI1ACwUbFV/SSgi41xYv05
Lrx4kpSmGL2+T6pnz7dICg2icbPZNQasEKwdWKmcd9ZjVueqdK1FmFPxGBJh71BW
KcGAkcMbEIdg3edPMbUjLbZ0bCZPmlbhqfJfFRtlAXmuMbF/MMMgvuP+tlULFax5
+xL4ORtgzifGonD/WKfWbrZ7fT0izQ==
=+G2A
-----END PGP SIGNATURE-----

--j9s9wGVNtit22hNfKuJ4gG5AXcFDrKD2s--
