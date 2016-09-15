From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Thu, 15 Sep 2016 21:35:50 +0200
Message-ID: <57DAF816.6040106@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="gCnBcQ1mSLdxVkOtqgAlXKJUvi49MFCWd"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
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
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4670-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gCnBcQ1mSLdxVkOtqgAlXKJUvi49MFCWd
Content-Type: multipart/mixed; boundary="2jrGIuWNgQwcrNJkqhn7tgafhkAQ0Md8q";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Kees Cook <keescook@chromium.org>,
 Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
 "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
 Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Message-ID: <57DAF816.6040106@digikod.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-19-mic@digikod.net>
 <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
 <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
In-Reply-To: <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>

--2jrGIuWNgQwcrNJkqhn7tgafhkAQ0Md8q
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 15/09/2016 03:25, Andy Lutomirski wrote:
> On Wed, Sep 14, 2016 at 3:11 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>> On 14/09/2016 20:27, Andy Lutomirski wrote:
>>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digik=
od.net> wrote:
>>>> Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initi=
ally
>>>> set for all cgroup except the root. The flag is clear when a new pro=
cess
>>>> without the no_new_privs flags is attached to the cgroup.
>>>>
>>>> If a cgroup is landlocked, then any new attempt, from an unprivilege=
d
>>>> process, to attach a process without no_new_privs to this cgroup wil=
l
>>>> be denied.
>>>
>>> Until and unless everyone can agree on a way to properly namespace,
>>> delegate, etc cgroups, I think that trying to add unprivileged
>>> semantics to cgroups is nuts.  Given the big thread about cgroup v2,
>>> no-internal-tasks, etc, I just don't see how this approach can be
>>> viable.
>>
>> As far as I can tell, the no_new_privs flag of at task is not related =
to
>> namespaces. The CGRP_NO_NEW_PRIVS flag is only a cache to quickly acce=
ss
>> the no_new_privs property of *tasks* in a cgroup. The semantic is unch=
anged.
>>
>> Using cgroup is optional, any task could use the seccomp-based
>> landlocking instead. However, for those that want/need to manage a
>> security policy in a more dynamic way, using cgroups may make sense.
>>
>> I though cgroup delegation was OK in the v2, isn't it the case? Do you=

>> have some links?
>>
>>>
>>> Can we try to make landlock work completely independently of cgroups
>>> so that it doesn't get stuck and so that programs can use it without
>>> worrying about cgroup v1 vs v2, interactions with cgroup managers,
>>> cgroup managers that (supposedly?) will start migrating processes
>>> around piecemeal and almost certainly blowing up landlock in the
>>> process, etc?
>>
>> This RFC handle both cgroup and seccomp approaches in a similar way. I=

>> don't see why building on top of cgroup v2 is a problem. Is there
>> security issues with delegation?
>=20
> What I mean is: cgroup v2 delegation has a functionality problem.
> Tejun says [1]:
>=20
> We haven't had to face this decision because cgroup has never properly
> supported delegating to applications and the in-use setups where this
> happens are custom configurations where there is no boundary between
> system and applications and adhoc trial-and-error is good enough a way
> to find a working solution.  That wiggle room goes away once we
> officially open this up to individual applications.
>=20
> Unless and until that changes, I think that landlock should stay away
> from cgroups.  Others could reasonably disagree with me.
>=20
> [1] https://lkml.kernel.org/r/20160909225747.GA30105@mtj.duckdns.org
>=20

I don't get the same echo here:
https://lkml.kernel.org/r/20160826155026.GD16906@mtj.duckdns.org

On 26/08/2016 17:50, Tejun Heo wrote:
> Please refer to "2-5. Delegation" of Documentation/cgroup-v2.txt.
> Delegation on v1 is broken on both core and specific controller
> behaviors and thus discouraged.  On v2, delegation should work just
> fine.

Tejun, could you please clarify if there is still a problem with cgroup
v2 delegation?

This patch only implement a cache mechanism with the CGRP_NO_NEW_PRIVS
flag. If cgroups can group processes correctly, I don't see any
(security) issue here. It's the administrator choice to delegate a part
of the cgroup management. It's then the delegatee responsibility to
correctly put processes in cgroups. This is comparable to a process
which is responsible to correctly call seccomp(2).

 Micka=C3=ABl


--2jrGIuWNgQwcrNJkqhn7tgafhkAQ0Md8q--

--gCnBcQ1mSLdxVkOtqgAlXKJUvi49MFCWd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2vgXAAoJECLe/t9zvWqVi8gIAJ6DRqQNJUPZbyyiICaVTop0
O7KoyGy8b/IHwUNcKkkbWcPuKK+Gzh30spjyTB+o772LJpZZ25fkXYFPmiwZp/Bn
vqMeuSaM4KqIZvNakm8yW+kIrlHW0/JeEBIQtcO+KkTehTRd7BpgB0/x0fnyXtlr
naInE+0/V0qmrPoJ9cr9fK9TFW1CcS6eF0lILWywKiK7jIEMoBPy2yckfiS8Wd7N
gfXtLnNekLmbJbLzwztWGApUC6zCkAkgK64U+z8SAHrROi/Ox6kRSJlEA956RQHf
sKASjfv0Fj2t0Zb/tagFHVyYLxAFxG8/lw1+A/q597foxrrvqcEUGMM2/M6FXsE=
=s+er
-----END PGP SIGNATURE-----

--gCnBcQ1mSLdxVkOtqgAlXKJUvi49MFCWd--
