From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 22:20:51 +0200
Message-ID: <57C5EAA3.5090901@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
 <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
 <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="VtFkfotkljqaTuMQHWUTTdhvdt3rleLTM"
Cc: "kernel-hardening@lists.openwall.com"
 <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4512-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VtFkfotkljqaTuMQHWUTTdhvdt3rleLTM
Content-Type: multipart/mixed; boundary="UGaX28AgPIxjbjOBFhHhjOa9io0pQuMHN";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "kernel-hardening@lists.openwall.com"
 <kernel-hardening@lists.openwall.com>, Alexei Starovoitov <ast@kernel.org>,
 Tejun Heo <tj@kernel.org>, Sargun Dhillon <sargun@sargun.me>,
 Network Development <netdev@vger.kernel.org>,
 Linux API <linux-api@vger.kernel.org>, Kees Cook <keescook@chromium.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
 "David S . Miller" <davem@davemloft.net>, Daniel Mack <daniel@zonque.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <57C5EAA3.5090901@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
 <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
 <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
In-Reply-To: <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>

--UGaX28AgPIxjbjOBFhHhjOa9io0pQuMHN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 30/08/2016 20:55, Andy Lutomirski wrote:
> On Sun, Aug 28, 2016 at 2:42 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>>
>> On 28/08/2016 10:13, Andy Lutomirski wrote:
>>> On Aug 27, 2016 11:14 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net=
> wrote:
>>>>
>>>>
>>>> On 27/08/2016 22:43, Alexei Starovoitov wrote:
>>>>> On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=C3=ABl Sala=C3=BCn =
wrote:
>>>>>> On 27/08/2016 20:06, Alexei Starovoitov wrote:
>>>>>>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=C3=ABl Sala=C3=BC=
n wrote:
>>>>>>>> As said above, Landlock will not run an eBPF programs when not s=
trictly
>>>>>>>> needed. Attaching to a cgroup will have the same performance imp=
act as
>>>>>>>> attaching to a process hierarchy.
>>>>>>>
>>>>>>> Having a prog per cgroup per lsm_hook is the only scalable way I
>>>>>>> could come up with. If you see another way, please propose.
>>>>>>> current->seccomp.landlock_prog is not the answer.
>>>>>>
>>>>>> Hum, I don't see the difference from a performance point of view b=
etween
>>>>>> a cgroup-based or a process hierarchy-based system.
>>>>>>
>>>>>> Maybe a better option should be to use an array of pointers with N=

>>>>>> entries, one for each supported hook, instead of a unique pointer =
list?
>>>>>
>>>>> yes, clearly array dereference is faster than link list walk.
>>>>> Now the question is where to keep this prog_array[num_lsm_hooks] ?
>>>>> Since we cannot keep it inside task_struct, we have to allocate it.=

>>>>> Every time the task is creted then. What to do on the fork? That
>>>>> will require changes all over. Then the obvious optimization would =
be
>>>>> to share this allocated array of prog pointers across multiple task=
s...
>>>>> and little by little this new facility will look like cgroup.
>>>>> Hence the suggestion to put this array into cgroup from the start.
>>>>
>>>> I see your point :)
>>>>
>>>>>
>>>>>> Anyway, being able to attach an LSM hook program to a cgroup thank=
s to
>>>>>> the new BPF_PROG_ATTACH seems a good idea (while keeping the possi=
bility
>>>>>> to use a process hierarchy). The downside will be to handle an LSM=
 hook
>>>>>> program which is not triggered by a seccomp-filter, but this shoul=
d be
>>>>>> needed anyway to handle interruptions.
>>>>>
>>>>> what do you mean 'not triggered by seccomp' ?
>>>>> You're not suggesting that this lsm has to enable seccomp to be fun=
ctional?
>>>>> imo that's non starter due to overhead.
>>>>
>>>> Yes, for now, it is triggered by a new seccomp filter return value
>>>> RET_LANDLOCK, which can take a 16-bit value called cookie. This must=
 not
>>>> be needed but could be useful to bind a seccomp filter security poli=
cy
>>>> with a Landlock one. Waiting for Kees's point of view=E2=80=A6
>>>>
>>>
>>> I'm not Kees, but I'd be okay with that.  I still think that doing
>>> this by process hierarchy a la seccomp will be easier to use and to
>>> understand (which is quite important for this kind of work) than doin=
g
>>> it by cgroup.
>>>
>>> A feature I've wanted to add for a while is to have an fd that
>>> represents a seccomp layer, the idea being that you would set up your=

>>> seccomp layer (with syscall filter, landlock hooks, etc) and then you=

>>> would have a syscall to install that layer.  Then an unprivileged
>>> sandbox manager could set up its layer and still be able to inject ne=
w
>>> processes into it later on, no cgroups needed.
>>
>> A nice thing I didn't highlight about Landlock is that a process can
>> prepare a layer of rules (arraymap of handles + Landlock programs) and=

>> pass the file descriptors of the Landlock programs to another process.=

>> This process could then apply this programs to get sandboxed. However,=

>> for now, because a Landlock program is only triggered by a seccomp
>> filter (which do not follow the Landlock programs as a FD), they will =
be
>> useless.
>>
>> The FD referring to an arraymap of handles can also be used to update =
a
>> map and change the behavior of a Landlock program. A master process ca=
n
>> then add or remove restrictions to another process hierarchy on the fl=
y.
>=20
> Maybe this could be extended a little bit.  The fd could hold the
> seccomp filter *and* the LSM hook filters.  FMODE_EXECUTE could give
> the ability to install it and FMODE_WRITE could give the ability to
> modify it.
>=20

This is interesting! It should be possible to append the seccomp stack
of a source process to the seccomp stack of the target process when a
Landlock program is passed and then activated through seccomp(2).

For the FMODE_EXECUTE/FMODE_WRITE, are you suggesting to manage
permission of the eBPF program FD in a specific way?


--UGaX28AgPIxjbjOBFhHhjOa9io0pQuMHN--

--VtFkfotkljqaTuMQHWUTTdhvdt3rleLTM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXxeqjAAoJECLe/t9zvWqVGt0H/3oiueOdD3enFh76clTGyiyM
oLI2DMPRgXiEd2A6SMtBf2Z4LeE4ThKg0+Xapkwyq5iUPKuPmuZJxab0dttejf0y
doMSd8YnGXh0MWv7Nql8MmP4s5R+jJwrMZtNa3SRUTk2EJfZpEAqi6oJtYNx2yLY
3kFDu6SXbaKx5oflIz2+xXXYgSwC3V44vajGezPNsOlEgr9+EZn1tWYAv9Y60WY4
BXWHU/JePiN+qEHR3DXxftLLjiJIH9Rk4MfmNV2QYdw3X05XQeq1MtG/NQ5u+71f
ICgx5194GmiOciyDL15TGWLOeYV2fALcdlnGHcxWHLlQyVTOi+I4gZ004GWbLDI=
=xde1
-----END PGP SIGNATURE-----

--VtFkfotkljqaTuMQHWUTTdhvdt3rleLTM--
