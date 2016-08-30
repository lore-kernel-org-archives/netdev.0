From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Tue, 30 Aug 2016 21:51:36 +0200
Message-ID: <57C5E3C8.1080103@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWw6fTTugSFcBhW=fv09GrSXQ+vZxuG0ewb+cod8nq4MQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="iS68pljTlh2L1r0VbXfQSnmHJ4I1fSRTV"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        Kernel Hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Tejun Heo <tj@kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4508-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrWw6fTTugSFcBhW=fv09GrSXQ+vZxuG0ewb+cod8nq4MQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iS68pljTlh2L1r0VbXfQSnmHJ4I1fSRTV
Content-Type: multipart/mixed; boundary="1tA95sEOkeODQ2R2gdE5d6A5uwahQeFil";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
Message-ID: <57C5E3C8.1080103@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <CALCETrWw6fTTugSFcBhW=fv09GrSXQ+vZxuG0ewb+cod8nq4MQ@mail.gmail.com>
In-Reply-To: <CALCETrWw6fTTugSFcBhW=fv09GrSXQ+vZxuG0ewb+cod8nq4MQ@mail.gmail.com>

--1tA95sEOkeODQ2R2gdE5d6A5uwahQeFil
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 30/08/2016 18:06, Andy Lutomirski wrote:
> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> Hi,
>>
>> This series is a proof of concept to fill some missing part of seccomp=
 as the
>> ability to check syscall argument pointers or creating more dynamic se=
curity
>> policies. The goal of this new stackable Linux Security Module (LSM) c=
alled
>> Landlock is to allow any process, including unprivileged ones, to crea=
te
>> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox or =
the
>> OpenBSD Pledge. This kind of sandbox help to mitigate the security imp=
act of
>> bugs or unexpected/malicious behaviors in userland applications.
>=20
> Micka=C3=ABl, will you be at KS and/or LPC?
>=20

I won't be at KS/LPC but I will give a talk at Kernel Recipes (Paris)
for which registration will start Thursday (and will not last long). :)

 Micka=C3=ABl


--1tA95sEOkeODQ2R2gdE5d6A5uwahQeFil--

--iS68pljTlh2L1r0VbXfQSnmHJ4I1fSRTV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXxePNAAoJECLe/t9zvWqVD7gH/R/P8OY0f0gIgcwfp22iq+XG
dj6V72UyTuwaYpECkpit9eaXPdvPLSSMezPIvTtl6FFJz0Y/5njuEEGL+K6L5zrk
8xicrpS30jXmG2SPlGZSuWzWW3MThDGS2OLYKa/1FlWlwsxLIXQnyL7LsBihHV5C
7M0YzJw3he/Ip/MyNVvfR+opibT9dA+ZTpoD//Q7e6Zk3RZi8BYMjzwhreRFmJTY
3ZYjSzMXV1qHcz/alrFfc6UABKZ77WQu0kf2tAzykaSm4biqdMoWeuRYnxJi8JEg
g7BCyS2fwqEPgpDfWpGMY2oVP1eexlrrg4j2LvU7rkaIJKY81BEX3kZtncEfVLg=
=G+wn
-----END PGP SIGNATURE-----

--iS68pljTlh2L1r0VbXfQSnmHJ4I1fSRTV--
