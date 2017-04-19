From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to
 filesystem
Date: Thu, 20 Apr 2017 00:03:16 +0200
Message-ID: <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
 <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net>
 <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
 <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="emKu6OjdvuVt8fWB9bCN1wj8bwiuceHJW"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
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
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <k
To: Kees Cook <keescook@chromium.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Return-path: <kernel-hardening-return-7429-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--emKu6OjdvuVt8fWB9bCN1wj8bwiuceHJW
Content-Type: multipart/mixed; boundary="q7kqFQx1L6IgiuQQ8mrbK31H9A1f6eW5O";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>,
 Casey Schaufler <casey@schaufler-ca.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
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
Message-ID: <35272f2b-ec5f-d032-ae2e-9fc0b4c0e2e3@digikod.net>
Subject: Re: [PATCH net-next v6 04/11] landlock: Add LSM hooks related to
 filesystem
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-5-mic@digikod.net>
 <CAGXu5jJKNp8R5kZ1U=K7KwgnV=NvH5aoAbftA-05a_Sa4pOg1Q@mail.gmail.com>
 <9a69055a-b4cf-00b0-da5e-2e45ff88059c@digikod.net>
 <c122415d-c2be-d013-efb4-833ba87d144d@schaufler-ca.com>
 <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>
In-Reply-To: <CAGXu5jKCr1qPqJ8YWAjK1Lj-fThAhMnrxFW8twFcj6C9ODBpsA@mail.gmail.com>

--q7kqFQx1L6IgiuQQ8mrbK31H9A1f6eW5O
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/04/2017 01:40, Kees Cook wrote:
> On Tue, Apr 18, 2017 at 4:16 PM, Casey Schaufler <casey@schaufler-ca.co=
m> wrote:
>> On 4/18/2017 3:44 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>>> On 19/04/2017 00:17, Kees Cook wrote:
>>>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digik=
od.net> wrote:
>>>>> +void __init landlock_add_hooks(void)
>>>>> +{
>>>>> +       pr_info("landlock: Version %u", LANDLOCK_VERSION);
>>>>> +       landlock_add_hooks_fs();
>>>>> +       security_add_hooks(NULL, 0, "landlock");
>>>>> +       bpf_register_prog_type(&bpf_landlock_type);
>>>> I'm confused by the separation of hook registration here. The call t=
o
>>>> security_add_hooks is with count=3D0 is especially weird. Why isn't =
this
>>>> just a single call with security_add_hooks(landlock_hooks,
>>>> ARRAY_SIZE(landlock_hooks), "landlock")?
>>> Yes, this is ugly with the new security_add_hooks() with three argume=
nts
>>> but I wanted to split the hooks definition in multiple files.
>>
>> Why? I'll buy a good argument, but there are dangers in
>> allowing multiple calls to security_add_hooks().

I prefer to have one file per hook "family" (e.g. filesystem, network,
ptrace=E2=80=A6). This reduce the mess with all the included files (neede=
d for
LSM hook argument types) and make the files easier to read, understand
and maintain.

>>
>>>
>>> The current security_add_hooks() use lsm_append(lsm, &lsm_names) whic=
h
>>> is not exported. Unfortunately, calling multiple security_add_hooks()=

>>> with the same LSM name would register multiple names for the same LSM=
=E2=80=A6
>>> Is it OK if I modify this function to not add duplicated entries?
>>
>> It may seem absurd, but it's conceivable that a module might
>> have two hooks it wants called. My example is a module that
>> counts the number of times SELinux denies a process access to
>> things (which needs to be called before and after SELinux in
>> order to detect denials) and takes "appropriate action" if
>> too many denials occur. It would be weird, wonky and hackish,
>> but that never stopped anybody before.

Right, but now, with the new lsm_append(), module names are concatenated
("%s,%s") in the lsm_names variable. It would be nice to not pollute
this string with multiple time the same module name.

>=20
> If ends up being sane and clear, I'm fine with allowing multiple calls.=

>=20
> -Kees
>=20


--q7kqFQx1L6IgiuQQ8mrbK31H9A1f6eW5O--

--emKu6OjdvuVt8fWB9bCN1wj8bwiuceHJW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj33qQACgkQIt7+33O9
apXTvAf/QHvF12w1UsXR4vk1J00stmkpC2Y9C/TEPul+fMetrO/l1bpYusF/V6Bv
YkwZADvAw9Gwxrhb487yC5DUx/GiQOfSw9P9rjBKWPCNOCH8MUJvhOvKf5tboO3C
j74m0DjCzCPUyM2lQkZwvogLhez6j5zjTMsDjZ8+eq0yqDAdG34rmLAl63M7QO4I
uAnL1FLHNw9w44IFv1OLoGV1n/9U/ZjdofUtunkhQxXQWo4WzQhafdyZIDzz4k82
e+uhan3Je+zu69QpCfC9g5blUKJoyf50t9PZTEC4nZA+Z5PxTHjv7HSGgXGsa4LW
hy7XRMnGYjI19VkiIEQAnNR9CG0VMQ==
=tAEh
-----END PGP SIGNATURE-----

--emKu6OjdvuVt8fWB9bCN1wj8bwiuceHJW--
