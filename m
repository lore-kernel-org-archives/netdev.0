From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
Date: Wed, 5 Oct 2016 23:05:18 +0200
Message-ID: <57F56B0E.5090101@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-12-mic@digikod.net>
 <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
 <57D9D06C.2020007@digikod.net>
 <CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="qf6IAL2lJkFfWUjQonR13Hw7bxPjpaVmd"
Cc: Andy Lutomirski <luto@amacapital.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller"
 <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-4808-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--qf6IAL2lJkFfWUjQonR13Hw7bxPjpaVmd
Content-Type: multipart/mixed; boundary="Ds9XnapJoVMOgEM8IAIVBLL0kb4dApfKh";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 David Drysdale <drysdale@google.com>, "David S . Miller"
 <davem@davemloft.net>, Elena Reshetova <elena.reshetova@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 James Morris <james.l.morris@oracle.com>, Paul Moore <pmoore@redhat.com>,
 Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>,
 Tejun Heo <tj@kernel.org>, Will Drewry <wad@chromium.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 Linux API <linux-api@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Message-ID: <57F56B0E.5090101@digikod.net>
Subject: Re: [RFC v3 11/22] seccomp,landlock: Handle Landlock hooks per
 process hierarchy
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-12-mic@digikod.net>
 <CALCETrXm18nNDY-a+toBEcjKKh+zOCVG0=t3ufkpROOHdqfqJQ@mail.gmail.com>
 <57D9D06C.2020007@digikod.net>
 <CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA@mail.gmail.com>
In-Reply-To: <CAGXu5j+qowiyQuhifOBtupfPxp6XevdgF08BW4yzkVDTCha0xA@mail.gmail.com>

--Ds9XnapJoVMOgEM8IAIVBLL0kb4dApfKh
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 04/10/2016 01:52, Kees Cook wrote:
> On Wed, Sep 14, 2016 at 3:34 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>
>> On 14/09/2016 20:43, Andy Lutomirski wrote:
>>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digik=
od.net> wrote:
>>>> A Landlock program will be triggered according to its subtype/origin=

>>>> bitfield. The LANDLOCK_FLAG_ORIGIN_SECCOMP value will trigger the
>>>> Landlock program when a seccomp filter will return RET_LANDLOCK.
>>>> Moreover, it is possible to return a 16-bit cookie which will be
>>>> readable by the Landlock programs in its context.
>>>
>>> Are you envisioning that the filters will return RET_LANDLOCK most of=

>>> the time or rarely?  If it's most of the time, then maybe this could
>>> be simplified a bit by unconditionally calling the landlock filter an=
d
>>> letting the landlock filter access a struct seccomp_data if needed.
>>
>> Exposing seccomp_data in a Landlock context may be a good idea. The ma=
in
>> implication is that Landlock programs may then be architecture specifi=
c
>> (if dealing with data) as seccomp filters are. Another point is that i=
t
>> remove any direct binding between seccomp filters and Landlock program=
s.
>> I will try this (more simple) approach.
>=20
> Yeah, I would prefer that the seccomp code isn't doing list management
> to identify the landlock hooks to trigger, etc. I think that's better
> done on the LSM side. And since multiple seccomp filters could trigger
> landlock, it may be best to just leave the low 16 bits unused
> entirely. Then all state management is handled by the landlock eBPF
> maps, not a value coming from seccomp that can get stomped on by new
> filters, etc.

Right, this approach should be simpler, more efficient and independent
from seccomp. This will be in the next RFC.


--Ds9XnapJoVMOgEM8IAIVBLL0kb4dApfKh--

--qf6IAL2lJkFfWUjQonR13Hw7bxPjpaVmd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX9WsOAAoJECLe/t9zvWqVj4kH/iinhcCE8P90Jp70JHkaveI7
sT0KhThgG6F3WvsELCoYrpDTXKEqSqhTfzaUcnkgAYYqkKrqgVrYEJscd11an7NF
K8SeRnL2MCHusIN2HnUktDW8w5LikRzNfl1vK8oXGWbkkvRrbvSy1AFywr8IQQML
ClK1jhDzEncuugBkhqhDqpzPBP08PlrheoHv4NG1N+2YkmwgoXS0+9CTzlE4+WDr
wwFrPtlf3nvqS+aQ33s4hPCbuPLGzNTLBX84JOyi8qPaEJ4mwp6wWOVZpXwO5M7+
DolTOtJXc6aCSiCMETkeQq/dzrvBtrBrOsy2i8X0nHtPNVU0OneE2vOVFIiO1NY=
=YS+4
-----END PGP SIGNATURE-----

--qf6IAL2lJkFfWUjQonR13Hw7bxPjpaVmd--
