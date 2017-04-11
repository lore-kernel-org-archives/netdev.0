From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 07/11] landlock: Add ptrace
 restrictions
Date: Tue, 11 Apr 2017 09:19:40 +0200
Message-ID: <58fa97b0-61bf-a8c1-2800-07190dcd919e@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-8-mic@digikod.net>
 <CAEiveUdXGEOywJoYTsBcxCp02_2gtj7Zw0zT_YdGWM3fJLYY7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="WUtqJr8wLWHtUW6SOt8heiL3Q10NB5TPT"
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
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
        Tejun Heo <tj@kernel.org>, Thomas G
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <kernel-hardening-return-7364-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAEiveUdXGEOywJoYTsBcxCp02_2gtj7Zw0zT_YdGWM3fJLYY7g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WUtqJr8wLWHtUW6SOt8heiL3Q10NB5TPT
Content-Type: multipart/mixed; boundary="iPK0hi77ePOrB7lKp1b7C7TaXgMKoHN6F";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Djalal Harouni <tixxdz@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
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
 LSM List <linux-security-module@vger.kernel.org>, netdev@vger.kernel.org
Message-ID: <58fa97b0-61bf-a8c1-2800-07190dcd919e@digikod.net>
Subject: Re: [kernel-hardening] [PATCH net-next v6 07/11] landlock: Add ptrace
 restrictions
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-8-mic@digikod.net>
 <CAEiveUdXGEOywJoYTsBcxCp02_2gtj7Zw0zT_YdGWM3fJLYY7g@mail.gmail.com>
In-Reply-To: <CAEiveUdXGEOywJoYTsBcxCp02_2gtj7Zw0zT_YdGWM3fJLYY7g@mail.gmail.com>

--iPK0hi77ePOrB7lKp1b7C7TaXgMKoHN6F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 10/04/2017 08:48, Djalal Harouni wrote:
> On Wed, Mar 29, 2017 at 1:46 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>> A landlocked process has less privileges than a non-landlocked process=

>> and must then be subject to additional restrictions when manipulating
>> processes. To be allowed to use ptrace(2) and related syscalls on a
>> target process, a landlocked process must have a subset of the target
>> process' rules.
>>
>> New in v6
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: James Morris <james.l.morris@oracle.com>
>> Cc: Kees Cook <keescook@chromium.org>
>> Cc: Serge E. Hallyn <serge@hallyn.com>
>> ---
>>  security/landlock/Makefile       |   2 +-
>>  security/landlock/hooks_ptrace.c | 126 ++++++++++++++++++++++++++++++=
+++++++++
>>  security/landlock/hooks_ptrace.h |  11 ++++
>>  security/landlock/init.c         |   2 +
>>  4 files changed, 140 insertions(+), 1 deletion(-)
>>  create mode 100644 security/landlock/hooks_ptrace.c
>>  create mode 100644 security/landlock/hooks_ptrace.h
>>
> [...]
>=20
>> +/**
>> + * landlock_ptrace_access_check - determine whether the current proce=
ss may
>> + *                               access another
>> + *
>> + * @child: the process to be accessed
>> + * @mode: the mode of attachment
>> + *
>> + * If the current task has Landlock rules, then the child must have a=
t least
>> + * the same rules.  Else denied.
>> + *
>> + * Determine whether a process may access another, returning 0 if per=
mission
>> + * granted, -errno if denied.
>> + */
>> +static int landlock_ptrace_access_check(struct task_struct *child,
>> +               unsigned int mode)
>> +{
>> +       if (!landlocked(current))
>> +               return 0;
>> +
>> +       if (!landlocked(child))
>> +               return -EPERM;
>> +
>> +       if (landlock_task_has_subset_events(current, child))
>> +               return 0;
>> +
>> +       return -EPERM;
>> +}
>> +
>=20
> Maybe you want to check the mode argument here if it is a
> PTRACE_ATTACH which may translate to read/writes ? PTRACE_READ are
> normally for reads only. Or also which creds were used if this was a
> direct syscall or a filesystem call through procfs.

The idea is to mimic the behavior of UID/GID checks, namespaces and so
on. A hierarchy of Landlock rules has a similar semantic as namespaces,
at least for now with the FS event.

>=20
> I'm bringing this, since you may want to make some room for landlock
> ptrace events and what others may want to do with it. Also I'm

I don't see any no problem to add a ptrace event in the future as long
as the composition with this default rule is a logical AND to allow a
ptrace action.

It would be possible to relax this default policy for rules with a
dedicated option flag, but the current behavior is a sane one from a
security point of view.

> planning to send another v2 RFC for procfs separate instances [1], the
> aim is to give LSMs a security_ptrace_access_check hook path when
> dealing with /proc/<pids>/ [2]  . Right now LSMs don't really have a
> security path there, and the implementation does not guarantee that.
> With this Yama ptrace scope or other LSMs may take advantage of it and
> check the 'PTRACE_MODE_READ_FSCRED' mode for filesystem accesses.

Interesting, feel free to CC me.

> That's why I think it would be better if the default landlock ptrace
> semantics are not that wide.
>=20
> Thanks!
>=20
> [1] https://lkml.org/lkml/2017/3/30/670
> [2] http://lxr.free-electrons.com/source/fs/proc/base.c#L719
>=20

If a task is allowed to ptrace/read the memory of another task with
different privileges, the tracer could also access sensitive data not
allowed otherwise.

Do you have an use case where this constraint would be an issue?

 Micka=C3=ABl


--iPK0hi77ePOrB7lKp1b7C7TaXgMKoHN6F--

--WUtqJr8wLWHtUW6SOt8heiL3Q10NB5TPT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAljsg40ACgkQIt7+33O9
apW43Af/WE/Y8YuuIQrCNKpdOxdQsVRY7FbbEiVZcY06CznsmpRv20itKQBKSRkx
qaKwLxqid41ZhJxwFu42gQPqUTj427oHkoov1zn5r04Ht9SWDcOYETDPHxxa7i4Y
dvhTyXWmWD+Unxlpqzum/yDSg9Mr9B3nTnNtb2LlCmZVg+gaGN0WR7axJjKr38TK
9iB5za5YXJUZad9xNlSmnvSLoly69xCbaxGxqzpAAWPYR5MSjEYQH0pNpJSyin5q
4z55VtvKofkXFwJQ2kTgCLUf5bNal426hdzrIA86Vh9oOxPPUqPt3+DDxoSHPxMU
hJ5HbYOs/vazKjFS2jPvgxQUeVz+Cg==
=h8Ph
-----END PGP SIGNATURE-----

--WUtqJr8wLWHtUW6SOt8heiL3Q10NB5TPT--
