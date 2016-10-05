From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
Date: Wed, 5 Oct 2016 22:30:02 +0200
Message-ID: <57F562CA.7080300@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd> <57E16D07.4050301@digikod.net>
 <CAGXu5jLp=GMpjqdCCPWeKHNseEv5DLPC7YN6EwhR1PJsei5cHw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="K65skR0GWQxSWkEmSBJ1uR0qUDL6SOnjQ"
Cc: Pavel Machek <pavel@ucw.cz>, LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        Network Dev
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-4803-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jLp=GMpjqdCCPWeKHNseEv5DLPC7YN6EwhR1PJsei5cHw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--K65skR0GWQxSWkEmSBJ1uR0qUDL6SOnjQ
Content-Type: multipart/mixed; boundary="tOwjxlMXlbVgqR7reOf2Cx25pX7MujfUv";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: Pavel Machek <pavel@ucw.cz>, LKML <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 James Morris <james.l.morris@oracle.com>, Paul Moore <pmoore@redhat.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>
Message-ID: <57F562CA.7080300@digikod.net>
Subject: Re: [RFC v2 00/10] Landlock LSM: Unprivileged sandboxing
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <20160915091902.GA13132@amd> <57E16D07.4050301@digikod.net>
 <CAGXu5jLp=GMpjqdCCPWeKHNseEv5DLPC7YN6EwhR1PJsei5cHw@mail.gmail.com>
In-Reply-To: <CAGXu5jLp=GMpjqdCCPWeKHNseEv5DLPC7YN6EwhR1PJsei5cHw@mail.gmail.com>

--tOwjxlMXlbVgqR7reOf2Cx25pX7MujfUv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 04/10/2016 00:56, Kees Cook wrote:
> On Tue, Sep 20, 2016 at 10:08 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>
>> On 15/09/2016 11:19, Pavel Machek wrote:
>>> Hi!
>>>
>>>> This series is a proof of concept to fill some missing part of secco=
mp as the
>>>> ability to check syscall argument pointers or creating more dynamic =
security
>>>> policies. The goal of this new stackable Linux Security Module (LSM)=
 called
>>>> Landlock is to allow any process, including unprivileged ones, to cr=
eate
>>>> powerful security sandboxes comparable to the Seatbelt/XNU Sandbox o=
r the
>>>> OpenBSD Pledge. This kind of sandbox help to mitigate the security i=
mpact of
>>>> bugs or unexpected/malicious behaviors in userland applications.
>>>>
>>>> The first RFC [1] was focused on extending seccomp while staying at =
the syscall
>>>> level. This brought a working PoC but with some (mitigated) ToCToU r=
ace
>>>> conditions due to the seccomp ptrace hole (now fixed) and the non-at=
omic
>>>> syscall argument evaluation (hence the LSM hooks).
>>>
>>> Long and nice description follows. Should it go to Documentation/
>>> somewhere?
>>>
>>> Because some documentation would be useful...
>>>                                                               Pavel
>>
>> Right, but I was looking for feedback before investing in documentatio=
n. :)
>=20
> Heh, understood. There are a number of grammar issues that slow me
> down when reading this, so when it does move into Documentation/, I'll
> have some English nit-picks. :)
>=20
> While reading I found myself wanting an explicit list of "guiding
> principles" for anyone implementing new hooks. It is touched on in
> several places (don't expose things, don't allow for privilege
> changes, etc). Having that spelled out somewhere would be nice.

Right, I'm going to try to create a more consistent documentation with
the "guiding principles".

 Micka=C3=ABl


--tOwjxlMXlbVgqR7reOf2Cx25pX7MujfUv--

--K65skR0GWQxSWkEmSBJ1uR0qUDL6SOnjQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX9WLKAAoJECLe/t9zvWqVoLgIAIvEs1LEWIjonrB4eq7A+mVo
INObpZ4ecZdICzqwSqz1kw7xPwUNDuyxIIU/V2R80pnHZvcKBUUmMn57Xm+80Wk3
kgAfypqezPno41o/rx1QoyDE/IAwD6dZ4YJ93K7DkhIanpQl6TIjxm1ViqZvv1a2
vOpPLsckX2Kt9I5rAEJLahEpdqL0aouxhlc8la2GReMiQkIkywf2IyE8AdglGkwT
XjnjmuqDAPF7fF2UBfMLExgs0trAwqEN5qxXTuspSvN45zkjLYg5SHaSKxhp2GD+
Dwjvyl+aqIK9MaCV5kPEfSQXojHIL2HhBiZusFSP4QYiruZNKWBFwEJ9XZ0d3ws=
=fjf+
-----END PGP SIGNATURE-----

--K65skR0GWQxSWkEmSBJ1uR0qUDL6SOnjQ--
