From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v3 19/22] landlock: Add interrupted origin
Date: Thu, 15 Sep 2016 00:14:43 +0200
Message-ID: <57D9CBD3.7030100@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-20-mic@digikod.net>
 <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="H4tLqI0LGvhoh5WBMCq726GUGMd0KgPnH"
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
Return-path: <kernel-hardening-return-4637-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--H4tLqI0LGvhoh5WBMCq726GUGMd0KgPnH
Content-Type: multipart/mixed; boundary="9ARiWJNHwiMxnqur83ibVoOnfb9lrgvrG";
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
Message-ID: <57D9CBD3.7030100@digikod.net>
Subject: Re: [RFC v3 19/22] landlock: Add interrupted origin
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-20-mic@digikod.net>
 <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>
In-Reply-To: <CALCETrUyqZEcJansuN=NX04CXv4ROtNqB25YZw7mBGuu43DFew@mail.gmail.com>

--9ARiWJNHwiMxnqur83ibVoOnfb9lrgvrG
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 14/09/2016 20:29, Andy Lutomirski wrote:
> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>> This third origin of hook call should cover all possible trigger paths=

>> (e.g. page fault). Landlock eBPF programs can then take decisions
>> accordingly.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@kernel.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Kees Cook <keescook@chromium.org>
>> ---
>=20
>=20
>>
>> +       if (unlikely(in_interrupt())) {
>=20
> IMO security hooks have no business being called from interrupts.
> Aren't they all synchronous things done by tasks?  Interrupts are
> driver things.
>=20
> Are you trying to check for page faults and such?

Yes, that was the idea you did put in my mind. Not sure how to deal with
this.


--9ARiWJNHwiMxnqur83ibVoOnfb9lrgvrG--

--H4tLqI0LGvhoh5WBMCq726GUGMd0KgPnH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJX2cvTAAoJECLe/t9zvWqVhMgH/j8wPM8xKRnzaWBH/cuw4ddN
DRmyWymzWG7lGEhAJtuxSg078AXDrJtEL3c172IQpoDnCwWzw5gLfobXpfshWBCp
iXE2A1rjGSc/RFAdd+CF6cfJCy8XQCZke87eAmWewedx5Z6WJeG2wHJQN3uEFkYx
3C3XC2I0CQ58iAUP/216A2WlCGmnPTmsDV2pFuogvG8477xyWWBrq2dYkd4vW0dY
ZhnQcAR+JRqFXE1ngo4uaHiVYGo3O0VsBt1eM/3rnQqCkBMoT7E2EUhCGC3TNtGw
Hk4qVFA+dUHR9DCeuKrWzgrt+oizUmRqlZ/aOLi7A+OEFgWGtK6CThdwPn9eM3w=
=JP2k
-----END PGP SIGNATURE-----

--H4tLqI0LGvhoh5WBMCq726GUGMd0KgPnH--
