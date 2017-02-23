From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v5 07/10] bpf: Add a Landlock sandbox example
Date: Thu, 23 Feb 2017 23:13:23 +0100
Message-ID: <372bb698-2078-93f4-72c4-9e430aa09ff9@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-8-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="a8cP3ev6Escei5qUtuk8bej2tTXHrfwIg"
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski
 <luto@amacapital.net>,
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
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Will Drewry <wad@chromi
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-6821-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170222012632.4196-8-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--a8cP3ev6Escei5qUtuk8bej2tTXHrfwIg
Content-Type: multipart/mixed; boundary="WIcPwgB6lxkVvchfBjaucN2wuWqA4GX8F";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: linux-kernel@vger.kernel.org
Cc: Alexei Starovoitov <ast@kernel.org>, Andy Lutomirski
 <luto@amacapital.net>, Arnaldo Carvalho de Melo <acme@kernel.org>,
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
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org
Message-ID: <372bb698-2078-93f4-72c4-9e430aa09ff9@digikod.net>
Subject: Re: [PATCH v5 07/10] bpf: Add a Landlock sandbox example
References: <20170222012632.4196-1-mic@digikod.net>
 <20170222012632.4196-8-mic@digikod.net>
In-Reply-To: <20170222012632.4196-8-mic@digikod.net>

--WIcPwgB6lxkVvchfBjaucN2wuWqA4GX8F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 22/02/2017 02:26, Micka=C3=ABl Sala=C3=BCn wrote:
> Add a basic sandbox tool to create a process isolated from some part of=

> the system. This sandbox create a read-only environment. It is only
> allowed to write to a character device such as a TTY:
>=20
>   # :> X
>   # echo $?
>   0
>   # ./samples/bpf/landlock1 /bin/sh -i
>   Launching a new sandboxed process.
>   # :> Y
>   cannot create Y: Operation not permitted
>=20
> Changes since v4:
> * write Landlock rule in C and compiled it with LLVM
> * remove cgroup handling
> * remove path handling: only handle a read-only environment
> * remove errno return codes
>=20
> Changes since v3:
> * remove seccomp and origin field: completely free from seccomp program=
s
> * handle more FS-related hooks
> * handle inode hooks and directory traversal
> * add faked but consistent view thanks to ENOENT
> * add /lib64 in the example
> * fix spelling
> * rename some types and definitions (e.g. SECCOMP_ADD_LANDLOCK_RULE)
>=20
> Changes since v2:
> * use BPF_PROG_ATTACH for cgroup handling
>=20
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>
> ---
>  samples/bpf/.gitignore       |  32 ++++++++++++++
>  samples/bpf/Makefile         |   4 ++
>  samples/bpf/bpf_load.c       |  26 +++++++++--
>  samples/bpf/landlock1_kern.c |  46 +++++++++++++++++++
>  samples/bpf/landlock1_user.c | 102 +++++++++++++++++++++++++++++++++++=
++++++++
>  5 files changed, 206 insertions(+), 4 deletions(-)
>  create mode 100644 samples/bpf/.gitignore
>  create mode 100644 samples/bpf/landlock1_kern.c
>  create mode 100644 samples/bpf/landlock1_user.c
>=20
> diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
> new file mode 100644
> index 000000000000..a7562a5ef4c2
> --- /dev/null
> +++ b/samples/bpf/.gitignore
> @@ -0,0 +1,32 @@
> +fds_example
> +lathist
> +lwt_len_hist
> +map_perf_test
> +offwaketime
> +sampleip
> +sockex1
> +sockex2
> +sockex3
> +sock_example
> +spintest
> +tc_l2_redirect
> +test_cgrp2_array_pin
> +test_cgrp2_attach
> +test_cgrp2_attach2
> +test_cgrp2_sock
> +test_cgrp2_sock2
> +test_current_task_under_cgroup
> +test_lru_dist
> +test_overhead
> +test_probe_write_user
> +trace_event
> +trace_output
> +tracex1
> +tracex2
> +tracex3
> +tracex4
> +tracex5
> +tracex6
> +xdp1
> +xdp2
> +xdp_tx_iptunnel

Please ignore this hunk, it was part of another patch series=E2=80=A6


--WIcPwgB6lxkVvchfBjaucN2wuWqA4GX8F--

--a8cP3ev6Escei5qUtuk8bej2tTXHrfwIg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlivXoMACgkQIt7+33O9
apVBxAf+PnNT5E80/vKvyWZABMk2vxQTROgNa2zY7xLmJtngzGOO3qZfIPvCf71C
huALJWKkqCeiWhz8a9LQtHvHccZM0sksva6iH6kCU+dYArASMLfwQc2drbtV6g9I
41CINz5C8xv1+q548gNwKkwpMSqAHWTfvEQrfZeazZj8gclVjPLAGye6PpoXs4uh
wN20Jigicmywx4NEVOjBqYtWmj2XduT2PWQ3HMqeJeQBtjmZ69uH2lqoDfXpHhHI
ChorM4o+KIwsurt48URENDGS7Yf/XjQLO3EI+9+mdQ9AALsHysbFsurSIByI0yU5
LwfFHMmBXJLntBPLfiMqqCNGqg6olw==
=B1UO
-----END PGP SIGNATURE-----

--a8cP3ev6Escei5qUtuk8bej2tTXHrfwIg--
