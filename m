From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
Date: Sat, 2 Sep 2017 15:19:30 +0200
Message-ID: <d603fc80-ee31-704d-5d42-67ca38e0800f@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-9-mic@digikod.net>
 <CAMXgnP64XxJGLyWqqNQ7P-Ok+UDydb+t8Pm9dUyXZ_9cx+Cfmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="LPEX4SLw9tcG5Ht2Iqlv7baDHGW2TBt3L"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
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
        Tejun Heo <tj@ker
To: Alban Crequy <alban.crequy@gmail.com>
Return-path: <kernel-hardening-return-9647-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAMXgnP64XxJGLyWqqNQ7P-Ok+UDydb+t8Pm9dUyXZ_9cx+Cfmw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LPEX4SLw9tcG5Ht2Iqlv7baDHGW2TBt3L
Content-Type: multipart/mixed; boundary="26EWw87RgULwiglfXrfILK2QjoxDFJ89a";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alban Crequy <alban.crequy@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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
 Linux API <linux-api@vger.kernel.org>,
 LSM <linux-security-module@vger.kernel.org>, netdev@vger.kernel.org,
 Michael Schubert <michael@kinvolk.io>, Iago Lopez Galeiras
 <iago@kinvolk.io>, Alban Crequy <alban@kinvolk.io>
Message-ID: <d603fc80-ee31-704d-5d42-67ca38e0800f@digikod.net>
Subject: Re: [PATCH net-next v7 08/10] bpf: Add a Landlock sandbox example
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-9-mic@digikod.net>
 <CAMXgnP64XxJGLyWqqNQ7P-Ok+UDydb+t8Pm9dUyXZ_9cx+Cfmw@mail.gmail.com>
In-Reply-To: <CAMXgnP64XxJGLyWqqNQ7P-Ok+UDydb+t8Pm9dUyXZ_9cx+Cfmw@mail.gmail.com>

--26EWw87RgULwiglfXrfILK2QjoxDFJ89a
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 01/09/2017 12:25, Alban Crequy wrote:
> Hi Micka=C3=ABl,
>=20
> On 21 August 2017 at 02:09, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net> =
wrote:
>> Add a basic sandbox tool to create a process isolated from some part o=
f
>> the system. This sandbox create a read-only environment. It is only
>> allowed to write to a character device such as a TTY:
> ...
>> +       /*
>> +        * This check allows the action on the file if it is a directo=
ry or a
>> +        * pipe. Otherwise, a message is printed to the eBPF log.
>> +        */
>> +       if (S_ISCHR(ret) || S_ISFIFO(ret))
>> +               return 0;
>=20
>=20
> The comment says "directory", but the code checks for "character device=
".
>=20
> Thanks!
> Alban
>=20

Fixed, thanks!


--26EWw87RgULwiglfXrfILK2QjoxDFJ89a--

--LPEX4SLw9tcG5Ht2Iqlv7baDHGW2TBt3L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmqr+IACgkQIt7+33O9
apU0OwgAm3iR12+mCshM4L1yyw7+OfJ+JWHZbwOQ+LSlqM957nKEZ4x4LedO6v8a
0i6yKQpwuCdGiXC9WAcTACQzNQDAWnL7L0lWOOz7RQZQyoekhf1HVQZpHhRFWcRC
1xi/1j/MWbNJZ1ZXHwaDpbQctz69ylR0zmHhd2hudqYCxg5Jh/H0mZIv+snfXDw9
9QbUzcjB3Bdt35qpshDKn1pB+Pmn7N3g8WBHdVwdgypY9i9pj6g4NI1Rx6QsP2SX
s4pH3Xk+wV5FqrxoTPajruQFr+NtUNbM/rO4GN9reaWp826SzAMklz5/jDWwAMXw
aZPSIn+8x721bMENZqoE3Zms6IfMQA==
=q9o+
-----END PGP SIGNATURE-----

--LPEX4SLw9tcG5Ht2Iqlv7baDHGW2TBt3L--
