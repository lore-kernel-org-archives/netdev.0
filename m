From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Thu, 15 Sep 2016 23:25:10 +0200
Message-ID: <57DB11B6.7090500@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="O3eSVVuCMVneGT8OKaWlt6EkL3kivSSDb"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        netdev@vger.ker
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4672-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914232418.GD60248@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--O3eSVVuCMVneGT8OKaWlt6EkL3kivSSDb
Content-Type: multipart/mixed; boundary="h1DWkuqOL5MWqIXXbB7Bo1vQ3gvVj46jA";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, cgroups@vger.kernel.org
Message-ID: <57DB11B6.7090500@digikod.net>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
 <20160914232418.GD60248@ast-mbp.thefacebook.com>
In-Reply-To: <20160914232418.GD60248@ast-mbp.thefacebook.com>

--h1DWkuqOL5MWqIXXbB7Bo1vQ3gvVj46jA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 15/09/2016 01:24, Alexei Starovoitov wrote:
> On Thu, Sep 15, 2016 at 01:02:22AM +0200, Micka=C3=ABl Sala=C3=BCn wrot=
e:
>>>
>>> I would suggest for the next RFC to do minimal 7 patches up to this p=
oint
>>> with simple example that demonstrates the use case.
>>> I would avoid all unpriv stuff and all of seccomp for the next RFC as=
 well,
>>> otherwise I don't think we can realistically make forward progress, s=
ince
>>> there are too many issues raised in the subsequent patches.
>>
>> I hope we will find a common agreement about seccomp vs cgroup=E2=80=A6=
 I think
>> both approaches have their advantages, can be complementary and nicely=

>> combined.
>=20
> I don't mind having both task based lsm and cgroup based as long as
> infrastracture is not duplicated and scaling issues from earlier versio=
n
> are resolved.

It should be much better with this RFC.

> I'm proposing to do cgroup only for the next RFC, since mine and Sargun=
's
> use case for this bpf+lsm+cgroup is _not_ security or sandboxing.

Well, LSM purpose is to do security stuff. The main goal of Landlock is
to bring security features to userland, including unprivileged
processes, at least via the seccomp interface [1].

> No need for unpriv, no_new_priv to cgroups are other things that Andy
> is concerned about.

I'm concern about security too! :)

>=20
>> Unprivileged sandboxing is the main goal of Landlock. This should not =
be
>> a problem, even for privileged features, thanks to the new subtype/acc=
ess.
>=20
> yes. the point that unpriv stuff can come later after agreement is reac=
hed.
> If we keep arguing about seccomp details this set won't go anywhere.
> Even in basic part (which is cgroup+bpf+lsm) are plenty of questions
> to be still agreed.

Using the seccomp(2) (unpriv) *interface* is OK according to a more
recent thread [1].

[1]
https://lkml.kernel.org/r/20160915044852.GA66000@ast-mbp.thefacebook.com

>=20
>> Agreed. With this RFC, the Checmate features (i.e. network helpers)
>> should be able to sit on top of Landlock.
>=20
> I think neither of them should be called fancy names for no technical r=
eason.
> We will have only one bpf based lsm. That's it and it doesn't
> need an obscure name. Directory name can be security/bpf/..stuff.c

I disagree on an LSM named "BPF". I first started with the "seccomp LSM"
name (first RFC) but I later realized that it is confusing because
seccomp is associated to its syscall and the underlying features. Same
thing goes for BPF. It is also artificially hard to grep on a name too
used in the kernel source tree.
Making an association between the generic eBPF mechanism and a security
centric approach (i.e. LSM) seems a bit reductive (for BPF). Moreover,
the seccomp interface [1] can still be used.

Landlock is a nice name to depict a sandbox as an enclave (i.e. a
landlocked country/state). I want to keep this name, which is simple,
express the goal of Landlock nicely and is comparable to other sandbox
mechanisms as Seatbelt or Pledge.
Landlock should not be confused with the underlying eBPF implementation.
Landlock could use more than only eBPF in the future and eBPF could be
used in other LSM as well.

 Micka=C3=ABl


--h1DWkuqOL5MWqIXXbB7Bo1vQ3gvVj46jA--

--O3eSVVuCMVneGT8OKaWlt6EkL3kivSSDb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2xG2AAoJECLe/t9zvWqVxNgH/0OSy0Qxz3fnRgd61Ekj6j5s
llh1ceHlo922+21YqtZV7z4lwqKKKFXZmbOoO4n+U9uQJJPHCzFYwIfJdnxa+lC7
adaCKy4RgguyuWBQBxKfMv7mG5roOvBX6OYIF744tsId8D08zkA1lOh1w+ev/k+D
s5MAoiOBulFxoDmuGAP42DLNu8gh8F5Y6ScgqBVLLTItNggwpdjnlSTS/D+hoIu+
UFKCwxzxAjDav9wEKx0h/gJI6xOI78AL4vHDwfWDO9IZDPsXeE27dEm+J00FCJ9e
sUSpc+11l8J5/mI3wVTrGF67AlRwr5Tt3VH9ioQWg+LGCeypXJlJ1OTu3cYtRgk=
=3M+j
-----END PGP SIGNATURE-----

--O3eSVVuCMVneGT8OKaWlt6EkL3kivSSDb--
