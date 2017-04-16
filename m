From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v6 02/11] bpf,landlock: Define an eBPF program
 type for Landlock
Date: Sun, 16 Apr 2017 23:57:11 +0200
Message-ID: <2fbc99a6-f190-f335-bd14-04bdeed35571@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="l4RSHgsE1ljw0TLilDEeg9dMx0cUfaoVg"
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
Return-path: <kernel-hardening-return-7379-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170328234650.19695-3-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--l4RSHgsE1ljw0TLilDEeg9dMx0cUfaoVg
Content-Type: multipart/mixed; boundary="Sl2U4hicOOk1NDqHQfKwkPJnOl5lBP9hd";
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
Message-ID: <2fbc99a6-f190-f335-bd14-04bdeed35571@digikod.net>
Subject: Re: [PATCH net-next v6 02/11] bpf,landlock: Define an eBPF program
 type for Landlock
References: <20170328234650.19695-1-mic@digikod.net>
 <20170328234650.19695-3-mic@digikod.net>
In-Reply-To: <20170328234650.19695-3-mic@digikod.net>

--Sl2U4hicOOk1NDqHQfKwkPJnOl5lBP9hd
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 29/03/2017 01:46, Micka=C3=ABl Sala=C3=BCn wrote:
> Add a new type of eBPF program used by Landlock rules.
>=20
> This new BPF program type will be registered with the Landlock LSM
> initialization.
>=20
> Add an initial Landlock Kconfig.
>=20
> Changes since v5:
> * rename file hooks.c to init.c
> * fix spelling
>=20
> Changes since v4:
> * merge a minimal (not enabled) LSM code and Kconfig in this commit
>=20
> Changes since v3:
> * split commit
> * revamp the landlock_context:
>   * add arch, syscall_nr and syscall_cmd (ioctl, fcntl=E2=80=A6) to be =
able to
>     cross-check action with the event type
>   * replace args array with dedicated fields to ease the addition of ne=
w
>     fields
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
>  include/linux/landlock.h       |  23 ++++++++
>  include/uapi/linux/bpf.h       | 105 +++++++++++++++++++++++++++++++++=
++
>  security/Kconfig               |   1 +
>  security/Makefile              |   2 +
>  security/landlock/Kconfig      |  18 ++++++
>  security/landlock/Makefile     |   3 +
>  security/landlock/common.h     |  25 +++++++++
>  security/landlock/init.c       | 123 +++++++++++++++++++++++++++++++++=
++++++++
>  tools/include/uapi/linux/bpf.h | 105 +++++++++++++++++++++++++++++++++=
++
>  9 files changed, 405 insertions(+)
>  create mode 100644 include/linux/landlock.h
>  create mode 100644 security/landlock/Kconfig
>  create mode 100644 security/landlock/Makefile
>  create mode 100644 security/landlock/common.h
>  create mode 100644 security/landlock/init.c
>
[...]
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 0eb71ab9b4fd..619b1f8707cc 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -114,6 +114,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_LWT_IN,
>  	BPF_PROG_TYPE_LWT_OUT,
>  	BPF_PROG_TYPE_LWT_XMIT,
> +	BPF_PROG_TYPE_LANDLOCK,
>  };
> =20
>  enum bpf_attach_type {
> @@ -661,4 +662,108 @@ struct xdp_md {
>  	__u32 data_end;
>  };
> =20
> +/**
> + * enum landlock_subtype_event - event occurring when an action is per=
formed on
> + * a particular kernel object
> + *
> + * An event is a policy decision point which exposes the same context =
type
> + * (especially the same arg[0-9] field types) for each rule execution.=

> + *
> + * @LANDLOCK_SUBTYPE_EVENT_UNSPEC: invalid value
> + * @LANDLOCK_SUBTYPE_EVENT_FS: generic filesystem event
> + */
> +enum landlock_subtype_event {
> +	LANDLOCK_SUBTYPE_EVENT_UNSPEC,
> +	LANDLOCK_SUBTYPE_EVENT_FS,
> +};
> +#define _LANDLOCK_SUBTYPE_EVENT_LAST LANDLOCK_SUBTYPE_EVENT_FS
[...]
> +/**
> + * DOC: landlock_action_fs
> + *
> + * - %LANDLOCK_ACTION_FS_EXEC: execute a file or walk through a direct=
ory
> + * - %LANDLOCK_ACTION_FS_WRITE: modify a file or a directory view (whi=
ch
> + *   include mount actions)
> + * - %LANDLOCK_ACTION_FS_READ: read a file or a directory
> + * - %LANDLOCK_ACTION_FS_NEW: create a file or a directory
> + * - %LANDLOCK_ACTION_FS_GET: open or receive a file
> + * - %LANDLOCK_ACTION_FS_REMOVE: unlink a file or remove a directory
> + *
> + * Each of the following actions are specific to syscall multiplexers.=
 They
> + * fill the syscall_cmd field from &struct landlock_context with their=
 custom
> + * command.
> + *
> + * - %LANDLOCK_ACTION_FS_IOCTL: ioctl command
> + * - %LANDLOCK_ACTION_FS_LOCK: flock or fcntl lock command
> + * - %LANDLOCK_ACTION_FS_FCNTL: fcntl command
> + */
> +#define LANDLOCK_ACTION_FS_EXEC			(1ULL << 0)
> +#define LANDLOCK_ACTION_FS_WRITE		(1ULL << 1)
> +#define LANDLOCK_ACTION_FS_READ			(1ULL << 2)
> +#define LANDLOCK_ACTION_FS_NEW			(1ULL << 3)
> +#define LANDLOCK_ACTION_FS_GET			(1ULL << 4)
> +#define LANDLOCK_ACTION_FS_REMOVE		(1ULL << 5)
> +#define LANDLOCK_ACTION_FS_IOCTL		(1ULL << 6)
> +#define LANDLOCK_ACTION_FS_LOCK			(1ULL << 7)
> +#define LANDLOCK_ACTION_FS_FCNTL		(1ULL << 8)
> +#define _LANDLOCK_ACTION_FS_NB			9
> +#define _LANDLOCK_ACTION_FS_MASK		((1ULL << _LANDLOCK_ACTION_FS_NB) - =
1)
> +
> +
> +/**
> + * struct landlock_context - context accessible to a Landlock rule
> + *
> + * @status: bitfield for future use (LANDLOCK_SUBTYPE_STATUS_*)
> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
> + *        as defined in <linux/audit.h>
> + * @syscall_nr: the system call number called by the current process (=
may be
> + *              useful to debug: find out from which syscall this requ=
est came
> + *              from)
> + * @syscall_cmd: contains the command used by a multiplexer syscall (e=
=2Eg.
> + *               ioctl, fcntl, flock)
> + * @event: event type (&enum landlock_subtype_event)
> + * @arg1: event's first optional argument
> + * @arg2: event's second optional argument
> + */
> +struct landlock_context {
> +	__u64 status;
> +	__u32 arch;
> +	__u32 syscall_nr;
> +	__u32 syscall_cmd;
> +	__u32 event;
> +	__u64 arg1;
> +	__u64 arg2;
> +};

I plan to simplify and make the FS event more generic for the IOCTL,
LOCK or FCNTL actions. The action flags for the
LANDLOCK_SUBTYPE_EVENT_FS event will remain the same but the syscall_cmd
field will be removed from struct landlock_context. Instead, one of
three dedicated events will be triggered in addition to one of this
three multiplexed actions.

The aim is to trigger the LANDLOCK_SUBTYPE_EVENT_FS for all file system
events (still including IOCTL/LOCK/FCNTL actions). This should avoid a
developer/user to forget such actions. However, when this kind of action
is triggered, a LANDLOCK_SUBTYPE_EVENT_FS_{IOCTL,LOCK,FCNTL} event will
follow. This enable to simplify the struct landlock_context while still
having it as generic as possible. The difference will be that the arg2
field for one of the LANDLOCK_SUBTYPE_EVENT_FS_{IOCTL,LOCK,FCNTL} events
will contain a custom IOCTL, LOCK or FCNTL command (currently in the
syscall_cmd field) instead of a LANDLOCK_ACTION_FS_* value. The same
logic could be used to tighten other actions in the future.

The HOOK_NEW_FS_CMD(...) from [04/11]:security/landlock/hooks_fs.c will
be replaced with dedicated calls.


I also plan to remove the arch and syscall_nr fields. This will make
struct landlock_context even more simple and arch-independent.


--Sl2U4hicOOk1NDqHQfKwkPJnOl5lBP9hd--

--l4RSHgsE1ljw0TLilDEeg9dMx0cUfaoVg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAljz6LcACgkQIt7+33O9
apV4rgf9GrOHBGGnLyS1yXyU6/4tSMLEhAw2DssyNtGgfyUtxNUVzK6xyj8hhWLV
W1iCJ+molIfZiK9Ja0pw8ZaF9ewtv8Tn4VoyTvc4xzeuWOb5xBcdzTCl230STXV1
ZxAbGZyn45mM5f9hsHM3p2U/9YPWd2mcG5hYMrWbVaTbJmTneBqsCfS6ipBuVJV7
TwyV/xYc9b5GLsW5PXCVZRjkIvppntQf67z6j1/H7YI/QRD+jWroPZnO+GBtpNAR
iOA1qHD2yx6/LzvjQyUzXBixP1l71MeWVHDSQb6kOa/LB0RH3f1V8eh/C9xoLyK4
43m+dUXTn8EwwwjfAddXfkHWf8qx5Q==
=oSq4
-----END PGP SIGNATURE-----

--l4RSHgsE1ljw0TLilDEeg9dMx0cUfaoVg--
