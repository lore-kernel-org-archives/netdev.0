From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 05/11] seccomp: Split put_seccomp_filter()
 with put_seccomp()
Date: Thu, 20 Apr 2017 00:18:04 +0200
Message-ID: <96024881-1bcc-33af-6285-d9a904de963e@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-6-mic@digikod.net>
 <CAGXu5jK3awbLYJTq9keb7oafUxU=_Ec9uMUHNWQH7skEhEg7WQ@mail.gmail.com>
 <9b420ecc-f062-8ab3-0b18-e09c60a00c6a@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PWs0Q1J0K2Ec48sLjhlCcfWTpdQ6uAHjE"
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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
        Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Will Drewry <wad@chromium.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <kernel-hardening-return-7431-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <9b420ecc-f062-8ab3-0b18-e09c60a00c6a@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PWs0Q1J0K2Ec48sLjhlCcfWTpdQ6uAHjE
Content-Type: multipart/mixed; boundary="2kpFJb6D2qvUV0dV2W5akJuaRugWD6OBW";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Casey Schaufler <casey@schaufler-ca.com>,
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
Message-ID: <96024881-1bcc-33af-6285-d9a904de963e@digikod.net>
Subject: Re: [PATCH net-next v6 05/11] seccomp: Split put_seccomp_filter()
 with put_seccomp()
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-6-mic@digikod.net>
 <CAGXu5jK3awbLYJTq9keb7oafUxU=_Ec9uMUHNWQH7skEhEg7WQ@mail.gmail.com>
 <9b420ecc-f062-8ab3-0b18-e09c60a00c6a@digikod.net>
In-Reply-To: <9b420ecc-f062-8ab3-0b18-e09c60a00c6a@digikod.net>

--2kpFJb6D2qvUV0dV2W5akJuaRugWD6OBW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 19/04/2017 00:47, Micka=C3=ABl Sala=C3=BCn wrote:
>=20
> On 19/04/2017 00:23, Kees Cook wrote:
>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod=
=2Enet> wrote:
>>> The semantic is unchanged. This will be useful for the Landlock
>>> integration with seccomp (next commit).
>>>
>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>>> Cc: Kees Cook <keescook@chromium.org>
>>> Cc: Andy Lutomirski <luto@amacapital.net>
>>> Cc: Will Drewry <wad@chromium.org>
>>> ---
>>>  include/linux/seccomp.h |  4 ++--
>>>  kernel/fork.c           |  2 +-
>>>  kernel/seccomp.c        | 18 +++++++++++++-----
>>>  3 files changed, 16 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>>> index ecc296c137cd..e25aee2cdfc0 100644
>>> --- a/include/linux/seccomp.h
>>> +++ b/include/linux/seccomp.h
>>> @@ -77,10 +77,10 @@ static inline int seccomp_mode(struct seccomp *s)=

>>>  #endif /* CONFIG_SECCOMP */
>>>
>>>  #ifdef CONFIG_SECCOMP_FILTER
>>> -extern void put_seccomp_filter(struct task_struct *tsk);
>>> +extern void put_seccomp(struct task_struct *tsk);
>>>  extern void get_seccomp_filter(struct task_struct *tsk);
>>>  #else  /* CONFIG_SECCOMP_FILTER */
>>> -static inline void put_seccomp_filter(struct task_struct *tsk)
>>> +static inline void put_seccomp(struct task_struct *tsk)
>>>  {
>>>         return;
>>>  }
>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>> index 6c463c80e93d..a27d8e67ce33 100644
>>> --- a/kernel/fork.c
>>> +++ b/kernel/fork.c
>>> @@ -363,7 +363,7 @@ void free_task(struct task_struct *tsk)
>>>  #endif
>>>         rt_mutex_debug_task_free(tsk);
>>>         ftrace_graph_exit_task(tsk);
>>> -       put_seccomp_filter(tsk);
>>> +       put_seccomp(tsk);
>>>         arch_release_task_struct(tsk);
>>>         if (tsk->flags & PF_KTHREAD)
>>>                 free_kthread_struct(tsk);
>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>> index 65f61077ad50..326f79e32127 100644
>>> --- a/kernel/seccomp.c
>>> +++ b/kernel/seccomp.c
>>> @@ -64,6 +64,8 @@ struct seccomp_filter {
>>>  /* Limit any path through the tree to 256KB worth of instructions. *=
/
>>>  #define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
>>>
>>> +static void put_seccomp_filter(struct seccomp_filter *filter);
>>
>> Can this be reorganized easily to avoid a forward-declaration?
>=20
> I didn't want to move too much code but I will.
>=20
>>
>>> +
>>>  /*
>>>   * Endianness is explicitly ignored and left for BPF program authors=
 to manage
>>>   * as per the specific architecture.
>>> @@ -314,7 +316,7 @@ static inline void seccomp_sync_threads(void)
>>>                  * current's path will hold a reference.  (This also
>>>                  * allows a put before the assignment.)
>>>                  */
>>> -               put_seccomp_filter(thread);
>>> +               put_seccomp_filter(thread->seccomp.filter);
>>>                 smp_store_release(&thread->seccomp.filter,
>>>                                   caller->seccomp.filter);
>>>
>>> @@ -476,10 +478,11 @@ static inline void seccomp_filter_free(struct s=
eccomp_filter *filter)
>>>         }
>>>  }
>>>
>>> -/* put_seccomp_filter - decrements the ref count of tsk->seccomp.fil=
ter */
>>> -void put_seccomp_filter(struct task_struct *tsk)
>>> +/* put_seccomp_filter - decrements the ref count of a filter */
>>> +static void put_seccomp_filter(struct seccomp_filter *filter)
>>>  {
>>> -       struct seccomp_filter *orig =3D tsk->seccomp.filter;
>>> +       struct seccomp_filter *orig =3D filter;
>>> +
>>>         /* Clean up single-reference branches iteratively. */
>>>         while (orig && atomic_dec_and_test(&orig->usage)) {
>>>                 struct seccomp_filter *freeme =3D orig;
>>> @@ -488,6 +491,11 @@ void put_seccomp_filter(struct task_struct *tsk)=

>>>         }
>>>  }
>>>
>>> +void put_seccomp(struct task_struct *tsk)
>>> +{
>>> +       put_seccomp_filter(tsk->seccomp.filter);
>>> +}
>>> +
>>>  static void seccomp_init_siginfo(siginfo_t *info, int syscall, int r=
eason)
>>>  {
>>>         memset(info, 0, sizeof(*info));
>>> @@ -914,7 +922,7 @@ long seccomp_get_filter(struct task_struct *task,=
 unsigned long filter_off,
>>>         if (copy_to_user(data, fprog->filter, bpf_classic_proglen(fpr=
og)))
>>>                 ret =3D -EFAULT;
>>>
>>> -       put_seccomp_filter(task);
>>> +       put_seccomp_filter(task->seccomp.filter);
>>>         return ret;
>>
>> I don't like that the arguments to get_seccomp_filter() and
>> put_seccomp_filter() are now different. I think they should match for
>> readability.
>=20
> OK, I can do that.
>=20

Kees, can I send this as a separate patch?


--2kpFJb6D2qvUV0dV2W5akJuaRugWD6OBW--

--PWs0Q1J0K2Ec48sLjhlCcfWTpdQ6uAHjE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlj34hwACgkQIt7+33O9
apUqiAf/W6XDRtopGxrSLPUSvfwzYK1ZxJ+POYZ170a5F8MW8I6jQ7XSYi1Ssezu
d+8nbA01nGXh7uEx19bErJZcksIXVSLqTQbmzdgQ9xJir8XMydB38PEQ1R0GHHfB
S/5hOKEeyHQtJMGdPfZ1kwSuzt428vO04G0OUaKDNZxBkNzOO9FIS9Cj5soF8CU/
N4dYq+fZRtDYIhb9ybFkvEn5n/IewOHC2UX6Ox7qu8Xi2+tKGzwEDngvUrlDAHY3
B2vAlUr3byi4keNFLgxb1paHDferHAjvjJTAMHTXNZYjapioqMUDm2QGb9QAWYJ8
yKMerLmmLoqzZ1hi+RxXKug28tziOw==
=heH2
-----END PGP SIGNATURE-----

--PWs0Q1J0K2Ec48sLjhlCcfWTpdQ6uAHjE--
