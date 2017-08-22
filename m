From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Tue, 22 Aug 2017 23:59:33 +0200
Message-ID: <753a3a91-23a4-bc63-27cb-12e764d3d5fc@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Dnvdt9AH49AkVNNJiXKdkOvxXQXGi39Ck"
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
Return-path: <kernel-hardening-return-9540-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-6-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Dnvdt9AH49AkVNNJiXKdkOvxXQXGi39Ck
Content-Type: multipart/mixed; boundary="ibiW1j3iD6nWvBmPbJaOUn4pko8Ovx8GU";
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
Message-ID: <753a3a91-23a4-bc63-27cb-12e764d3d5fc@digikod.net>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
In-Reply-To: <20170821000933.13024-6-mic@digikod.net>

--ibiW1j3iD6nWvBmPbJaOUn4pko8Ovx8GU
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 21/08/2017 02:09, Micka=C3=ABl Sala=C3=BCn wrote:
> Handle 33 filesystem-related LSM hooks for the Landlock filesystem
> event: LANDLOCK_SUBTYPE_EVENT_FS.
>=20
> A Landlock event wrap LSM hooks for similar kernel object types (e.g.
> struct file, struct path...). Multiple LSM hooks can trigger the same
> Landlock event.
>=20
> Landlock handle nine coarse-grained actions: read, write, execute, new,=

> get, remove, ioctl, lock and fcntl. Each of them abstract LSM hook
> access control in a way that can be extended in the future.
>=20
> The Landlock LSM hook registration is done after other LSM to only run
> actions from user-space, via eBPF programs, if the access was granted b=
y
> major (privileged) LSMs.
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
>=20
> Changes since v6:
> * add 3 more sub-events: IOCTL, LOCK, FCNTL
>   https://lkml.kernel.org/r/2fbc99a6-f190-f335-bd14-04bdeed35571@digiko=
d.net
> * use the new security_add_hooks()
> * explain the -Werror=3Dunused-function
> * constify pointers
> * cleanup headers
>=20
> Changes since v5:
> * split hooks.[ch] into hooks.[ch] and hooks_fs.[ch]
> * add more documentation
> * cosmetic fixes
> * rebase (SCALAR_VALUE)
>=20
> Changes since v4:
> * add LSM hook abstraction called Landlock event
>   * use the compiler type checking to verify hooks use by an event
>   * handle all filesystem related LSM hooks (e.g. file_permission,
>     mmap_file, sb_mount...)
> * register BPF programs for Landlock just after LSM hooks registration
> * move hooks registration after other LSMs
> * add failsafes to check if a hook is not used by the kernel
> * allow partial raw value access form the context (needed for programs
>   generated by LLVM)
>=20
> Changes since v3:
> * split commit
> * add hooks dealing with struct inode and struct path pointers:
>   inode_permission and inode_getattr
> * add abstraction over eBPF helper arguments thanks to wrapping structs=

> ---
>  include/linux/lsm_hooks.h    |   5 +
>  security/landlock/Makefile   |   7 +-
>  security/landlock/common.h   |   2 +
>  security/landlock/hooks.c    |  83 ++++++
>  security/landlock/hooks.h    | 177 +++++++++++++
>  security/landlock/hooks_fs.c | 586 +++++++++++++++++++++++++++++++++++=
++++++++
>  security/landlock/hooks_fs.h |  19 ++
>  security/landlock/init.c     |  10 +
>  security/security.c          |  12 +-
>  9 files changed, 899 insertions(+), 2 deletions(-)
>  create mode 100644 security/landlock/hooks.c
>  create mode 100644 security/landlock/hooks.h
>  create mode 100644 security/landlock/hooks_fs.c
>  create mode 100644 security/landlock/hooks_fs.h

> diff --git a/security/landlock/init.c b/security/landlock/init.c
> index 09acbc74abd6..1e6660fed697 100644
> --- a/security/landlock/init.c
> +++ b/security/landlock/init.c
> @@ -10,8 +10,10 @@
> =20
>  #include <linux/bpf.h> /* enum bpf_access_type */
>  #include <linux/capability.h> /* capable */
> +#include <linux/lsm_hooks.h>
> =20
>  #include "common.h" /* LANDLOCK_* */
> +#include "hooks_fs.h"
> =20
> =20
>  static inline bool bpf_landlock_is_valid_access(int off, int size,
> @@ -23,6 +25,8 @@ static inline bool bpf_landlock_is_valid_access(int o=
ff, int size,
> =20
>  	switch (prog_subtype->landlock_rule.event) {
>  	case LANDLOCK_SUBTYPE_EVENT_FS:
> +		return landlock_is_valid_access_event_FS(off, size, type,
> +				&info->reg_type, prog_subtype);

I forgot to handle LANDLOCK_SUBTYPE_EVENT_FS_{IOCTL,LOCK_FCNTL} here and
I included some hunks in the wrong patches. I will fix this in the next
series and add tests for those anyway. :)

Regards,
 Micka=C3=ABl


--ibiW1j3iD6nWvBmPbJaOUn4pko8Ovx8GU--

--Dnvdt9AH49AkVNNJiXKdkOvxXQXGi39Ck
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlmcqUUACgkQIt7+33O9
apVSrQgAkpiEGSlcj4s42B8EP98Wq5IkvJbLVitw/iMEiWsXDO2vDp+9aWG1tXDB
lKSPkE/FdU6GCG8Unk0AETiDkG2zkcygiaOu1apcJ90V7ByVmvUUfT1EoRiYmam7
D75lEcqaP3tycXecTlAlTr3OQkE12HiZ2PscRt8HYZ/UIf6EeSDFwhOEUTH2YioW
osemeTd/DkNO6PEzJ9NrAkBsFn3jc9pi5b0+994N3ATTOxCPTcDSOGZ09zGrx9ni
RWVYsFZwpGCtYyKEFagP/vI0BRTlkM9Bh6ha3hpwi06s7St7JPuqZokL0/aHcikS
+n/4+J1x4kU9ydOoD/KuXXZ5NkdJdw==
=dAlT
-----END PGP SIGNATURE-----

--Dnvdt9AH49AkVNNJiXKdkOvxXQXGi39Ck--
