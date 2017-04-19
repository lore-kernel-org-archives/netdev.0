From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 09/11] seccomp: Enhance test_harness with an
 assert step mechanism
Date: Wed, 19 Apr 2017 23:51:35 +0200
Message-ID: <94ac6ddc-eaac-8548-f83f-826ddf05ac69@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-10-mic@digikod.net>
 <CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="SuV3BVsmJFtPw5AtNOTSpa4Kk39HtfI3K"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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
        Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Will Drewry <wad@chromium.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-7427-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SuV3BVsmJFtPw5AtNOTSpa4Kk39HtfI3K
Content-Type: multipart/mixed; boundary="I4bWgwnW7mtO2nF6o2F2dNeQORQ6AaKx4";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, David Drysdale
 <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
 Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
 Michael Kerrisk <mtk.manpages@gmail.com>, Paul Moore <paul@paul-moore.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
 Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <94ac6ddc-eaac-8548-f83f-826ddf05ac69@digikod.net>
Subject: Re: [PATCH net-next v6 09/11] seccomp: Enhance test_harness with an
 assert step mechanism
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-10-mic@digikod.net>
 <CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com>
In-Reply-To: <CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com>

--I4bWgwnW7mtO2nF6o2F2dNeQORQ6AaKx4
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/04/2017 02:02, Kees Cook wrote:
> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> This is useful to return an information about the error without being
>> able to write to TH_LOG_STREAM.
>>
>> Helpers from test_harness.h may be useful outside of the seccomp
>> directory.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Shuah Khan <shuah@kernel.org>
>> Cc: Will Drewry <wad@chromium.org>
>> ---
>>  tools/testing/selftests/seccomp/test_harness.h | 8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/tools/testing/selftests/seccomp/test_harness.h b/tools/te=
sting/selftests/seccomp/test_harness.h
>> index a786c69c7584..77e407663e06 100644
>> --- a/tools/testing/selftests/seccomp/test_harness.h
>> +++ b/tools/testing/selftests/seccomp/test_harness.h
>> @@ -397,7 +397,7 @@ struct __test_metadata {
>>         const char *name;
>>         void (*fn)(struct __test_metadata *);
>>         int termsig;
>> -       int passed;
>> +       __s8 passed;
>=20
> Why the reduction here? int is signed too?

Because the return code of a process is capped to 8 bits and I use a
negative value to not mess with the current interpretation of 0 (error)
and 1 (OK) for the "passed" variable.

>=20
>>         int trigger; /* extra handler after the evaluation */
>>         struct __test_metadata *prev, *next;
>>  };
>> @@ -476,6 +476,12 @@ void __run_test(struct __test_metadata *t)
>>                                         "instead of by signal (code: %=
d)\n",
>>                                         t->name,
>>                                         WEXITSTATUS(status));
>> +                       } else if (t->passed < 0) {
>> +                               fprintf(TH_LOG_STREAM,
>> +                                       "%s: Failed at step #%d\n",
>> +                                       t->name,
>> +                                       t->passed * -1);
>> +                               t->passed =3D 0;
>>                         }
>=20
> Instead of creating an overloaded mechanism here, perhaps have an
> option reporting mechanism that can be enabled. Like adding to
> __test_metadata "bool no_stream; int test_number;" and adding
> test_number++ to each ASSERT/EXCEPT call, and doing something like:
>=20
> if (t->no_stream) {
>                               fprintf(TH_LOG_STREAM,
>                                       "%s: Failed at step #%d\n",
>                                       t->name,
>                                        t->test_number);
> }
>=20
> It'd be a cleaner approach, maybe?

Good idea, we will then be able to use 255 steps!

Do you want me to send this as a separate patch?

Can we move test_harness.h outside of the seccomp directory to be
available to other subsystems as well?


--I4bWgwnW7mtO2nF6o2F2dNeQORQ6AaKx4--

--SuV3BVsmJFtPw5AtNOTSpa4Kk39HtfI3K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj32+cACgkQIt7+33O9
apWN1Af/VL2G2T7oAY/ckYQgFPK0nPoQxt0tZq05N/kycz0Fb6DXJq3WC7s5j9rZ
D2ZY6rKMKImCSZgW6bQZYimJsm/KtWAK7gyF+Hz/IcKun8MhYrbUbSQB4EwyfERK
ulIQupfUr1ssiHZRpffnOLb8gzKdusLRSHll91MyluVArVg41lRpzMcniEiZIdla
TFMk3C1mBgT62lH6r+HHdL5M94FI7C3UH1xKuVzyAZl/zqgLxYRjMGIhaxsNVdDS
NY5hYpP64GgAsrn50gkDKORjCS/r6SkJgV9h0we83SekXG11Am6efI1PzwgR6BuS
c3l3zc98FjWZr0Y34GNkirh3d0G4SA==
=KSWJ
-----END PGP SIGNATURE-----

--SuV3BVsmJFtPw5AtNOTSpa4Kk39HtfI3K--
