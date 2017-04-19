From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 00/11] Landlock LSM: Toward unprivileged
 sandboxing
Date: Wed, 19 Apr 2017 02:12:16 +0200
Message-ID: <a5597574-6a8c-b2ee-336c-48734071e6ff@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <CAGXu5jLpM13xmFf2_bcWH=db7LEavfpZswvPbAM3+66dBPtMTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="1t0Rfgn2t0N37lfjAhevO2o0vT1jVARoG"
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
Return-path: <kernel-hardening-return-7419-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jLpM13xmFf2_bcWH=db7LEavfpZswvPbAM3+66dBPtMTg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1t0Rfgn2t0N37lfjAhevO2o0vT1jVARoG
Content-Type: multipart/mixed; boundary="Hpm5fgWkkDoOkHvQhhfQ3l4mKAP3UvFsp";
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
Message-ID: <a5597574-6a8c-b2ee-336c-48734071e6ff@digikod.net>
Subject: Re: [PATCH net-next v6 00/11] Landlock LSM: Toward unprivileged
 sandboxing
References: <20170328234650.19695-1-mic@digikod.net>
 <CAGXu5jLpM13xmFf2_bcWH=db7LEavfpZswvPbAM3+66dBPtMTg@mail.gmail.com>
In-Reply-To: <CAGXu5jLpM13xmFf2_bcWH=db7LEavfpZswvPbAM3+66dBPtMTg@mail.gmail.com>

--Hpm5fgWkkDoOkHvQhhfQ3l4mKAP3UvFsp
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/04/2017 01:26, Kees Cook wrote:
> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> This sixth series add some changes to the previous one [1], including =
a simpler
>> rule inheritance hierarchy (similar to seccomp-bpf), a ptrace scope pr=
otection,
>> some file renaming (better feature identification per file), a future-=
proof
>> eBPF subtype and miscellaneous cosmetic fixes.
>=20
> Sorry for the delay in review! I finally had a chunk of time I could
> devote to this. I really like how it's heading. I still wonder about
> its overlap with seccomp (it's really only using the syscall now...),
> but that's just a detail. Getting the abstraction away from direct LSM
> hooks looks good.
>=20
>> There is as yet no way to allow a process to access only a subset of t=
he
>> filesystem where the subset is specified via a path or a file descript=
or.  This
>> feature is intentionally left out so as to minimize the amount of code=
 of this
>> patch series but will come in a following series.  However, it is poss=
ible to
>> check the file type, as done in the following example.
>=20
> I understand why you've taken a progressive approach here, but I think
> there are two fundamental areas where people will use Landlock: path
> evaluation and network address evaluation. I think it's worth
> expanding this series to include those two confinement examples, since
> that can help people understand what the "general" case will look
> like.

I agree that it would be more useful to add a path/FS evaluation,
however we agreed at LPC that it would be another patch series:
https://lkml.kernel.org/r/5828776A.1010104@digikod.net
It brings more complexity and a new kind of BPF map, which should be
reviewed in a separate series.

>=20
> As I mentioned in one of the patch review emails, I think there needs
> to be a clearer explanation of how usage counting works vs the
> "events" (which I think of as "rule tables" not events -- maybe it
> needs a new name?) and "rule" lists. I think I understand it, but I
> spent a lot of time trying to get there. More comments would help.

I though about different names and the previous one was PDP (for Policy
Decision Point) which is used in the literature, but "event" seems
easier to understand and close enough with "hook". Rule tables doesn't
seems to express what is the meaning to register an event/hook.

I'll add more comments to explain how it works.

>=20
> Finally, another thing I'm curious about is how to deal with the
> thread-sync issue. Seccomp uses its TSYNC thing, and I'd expect we'd
> want something similar for landlock... but that looks really hairy as
> far as locking goes. Perhaps it's already solved by using the same
> locking seccomp uses, in which case I'm less inclined to kick landlock
> out of seccomp.c. :)

I didn't work on it but it should be really similar to seccomp-bpf.

>=20
> Looks like it's coming along nicely! Thanks for continuing to work on t=
his!
>=20
> -Kees
>=20


--Hpm5fgWkkDoOkHvQhhfQ3l4mKAP3UvFsp--

--1t0Rfgn2t0N37lfjAhevO2o0vT1jVARoG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj2q2AACgkQIt7+33O9
apXxaAgAqVIZOsS3/3lornGMYaKG2m8KBlzBftzgrX5SV0s6fqOCG97kNRoFlCVR
6bOs/rsNoUzUa8ILtH65xMzk4bVpOKwMIj/UT86/BikZsRJUitYi4ZpmlUVo5/gN
REEGrBT7SB1WSxMAEBJWLLfGfLEG60D2WkiDLlUvqQxto1xtx9s7w5Z5jQC1tskM
Y6Z4Ne9+OIz1hcrUJwpNcZ/yet7XRza2xd9QFCbEK9aR1L4rPrpq1snqBzTYifNL
gFtKPSX56YsUNzWYEq8XM20kgGeerEWUX0dyaUwBUJWoOt/+5xsAqQubqr4mVDK4
p+da9VzFcv8nCyeIOYHunES9czJlfg==
=P+pX
-----END PGP SIGNATURE-----

--1t0Rfgn2t0N37lfjAhevO2o0vT1jVARoG--
