From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 19/22] landlock: Add interrupted origin
Date: Wed, 5 Oct 2016 23:01:05 +0200
Message-ID: <57F56A11.109@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-20-mic@digikod.net>
 <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>
 <57D9CBD3.7030100@digikod.net>
 <CALCETrWmp33g0_adWcLXLuQe7R2EeLchKGivQnEsK5A4nAwTfw@mail.gmail.com>
 <CAGXu5j+90zJTcfm2DMP04zu0pg832dKgSJgfFYxLVvV=CZk16g@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="QbGjVHmkCgd1kuhloFi7UJuXFM8iwtEQ2"
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
        Paul Moore <pmoore@redhat.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-4807-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5j+90zJTcfm2DMP04zu0pg832dKgSJgfFYxLVvV=CZk16g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QbGjVHmkCgd1kuhloFi7UJuXFM8iwtEQ2
Content-Type: multipart/mixed; boundary="GiHS6QJR9LRPB4Bvkv4J9dmBwf6CL0c24";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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
 "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
Message-ID: <57F56A11.109@digikod.net>
Subject: Re: [RFC v3 19/22] landlock: Add interrupted origin
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-20-mic@digikod.net>
 <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>
 <57D9CBD3.7030100@digikod.net>
 <CALCETrWmp33g0_adWcLXLuQe7R2EeLchKGivQnEsK5A4nAwTfw@mail.gmail.com>
 <CAGXu5j+90zJTcfm2DMP04zu0pg832dKgSJgfFYxLVvV=CZk16g@mail.gmail.com>
In-Reply-To: <CAGXu5j+90zJTcfm2DMP04zu0pg832dKgSJgfFYxLVvV=CZk16g@mail.gmail.com>

--GiHS6QJR9LRPB4Bvkv4J9dmBwf6CL0c24
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 04/10/2016 01:46, Kees Cook wrote:
> On Wed, Sep 14, 2016 at 6:19 PM, Andy Lutomirski <luto@amacapital.net> =
wrote:
>> On Wed, Sep 14, 2016 at 3:14 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>>
>>> On 14/09/2016 20:29, Andy Lutomirski wrote:
>>>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digi=
kod.net> wrote:
>>>>> This third origin of hook call should cover all possible trigger pa=
ths
>>>>> (e.g. page fault). Landlock eBPF programs can then take decisions
>>>>> accordingly.
>>>>>
>>>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>>>>> Cc: Alexei Starovoitov <ast@kernel.org>
>>>>> Cc: Andy Lutomirski <luto@amacapital.net>
>>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>>> Cc: Kees Cook <keescook@chromium.org>
>>>>> ---
>>>>
>>>>
>>>>>
>>>>> +       if (unlikely(in_interrupt())) {
>>>>
>>>> IMO security hooks have no business being called from interrupts.
>>>> Aren't they all synchronous things done by tasks?  Interrupts are
>>>> driver things.
>>>>
>>>> Are you trying to check for page faults and such?
>>>
>>> Yes, that was the idea you did put in my mind. Not sure how to deal w=
ith
>>> this.
>>>
>>
>> It's not so easy, unfortunately.  The easiest reliable way might be to=

>> set a TS_ flag on all syscall entries when TIF_SECCOMP or similar is
>> set.
>=20
> For making this series smaller, let's leave the idea idea of interrupt
> hooks out -- the intention is for stricter syscall filtering, yes?
>=20
> Once things are more well established and there's a use-case for this,
> it can be added back in.

Right, I'm no more convinced it's worth it.


--GiHS6QJR9LRPB4Bvkv4J9dmBwf6CL0c24--

--QbGjVHmkCgd1kuhloFi7UJuXFM8iwtEQ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX9WoRAAoJECLe/t9zvWqVEpcH/R44TEGL3LzKZz/gRIm8rV4x
qXfaPm6oyWOUI7per3s30OcNulV8Jub0ik3Ce+UHLXgGndXhVRLqkthrrWewP8hv
8o1lYVMWib0FbnLzAm2tyRnb52UK3MQv8Ina+QCwLSI1WX85kzJroHNVTX3J+3PT
zbQm+ZfuVXrUUPpHqyraDwC5qQPmkmpmHSTl7Wyy+XCGR2OI8lt5+iLJUNYIcyXj
mGKLaNpAsXOQG6OymgJo5e5nSjDPTQBvAiQjGt/vHGNnnLm6he1ErhvT4J61O5bX
WQCKOlJCCU3Wvd0D+yHK7ukRP5XnYkA9HlhjFpF8Hi2cWehM2/HP0qBTi15QLEg=
=oIPw
-----END PGP SIGNATURE-----

--QbGjVHmkCgd1kuhloFi7UJuXFM8iwtEQ2--
