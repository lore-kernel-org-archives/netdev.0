From: Justin Sanchez <jsanchez@cs.ucf.edu>
Subject: Re: [Bug 1030] New: racoon causes oops when implementing IPSec key
Date: 03 Aug 2003 01:51:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1059889883.1187.15.camel@mobile>
References: <89550000.1059833972@[10.10.2.4]>
	<20030802163333.A12217@electric-eye.fr.zoreil.com>
	<1059850039.1187.2.camel@mobile>
	<20030802212018.B14141@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-2Y8LE63gCCNUG9OvqJTX"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030802212018.B14141@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-2Y8LE63gCCNUG9OvqJTX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi. I had this problem on 2.6.0-test1 and -test2 and -test2-bk2, so I'll
try to report it. I'm new to the scene, so I apologize in advance for
this post.

Background. 2 machines. e100 cards on each, if it matters. ipsec-tools
0.2.2. I give each of them directives to use esp and ah in transport
mode. I turn on racoon on each box. I ping. Both panic. Following is
about the message:.

Unable to handle kernel NULL pointer dereference at virtual address
00000000
 printing eip:
c02bbd06
*pde =3D 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c02bbd06>]     Not tainted
EFLAGS: 00010206
EIP is at memcpy+0x1e/0x39
eax: 00000018   ebx: f6fe8a00   ecx: 00000006   edx: 00000000
esi: 00000000   edi: 00000000   ebp: c0562520   esp: f6fb5ccc
ds: 007b    es: 007b  ss:0068
Process racoon (pid: 418, threadinfo=3Df6fb4000 task=3Df6fbb300)
Stack:
Call Trace:
 xfrm_state_update
 pfkey_add
 parse_exthdrs
 pfkey_process
 pfkey_sendmsg
 sock_sendmsg
 verify_iovec
 sys_sendmsg
 sockfd_lookup
 sys_sendto
 sys_getsockname
 __pollwait
 update_process
 sys_send
 sys_socketcall
 syscall_call
Code: f3 a5 a8 02 74 02 66 a5 a8 01 74 01 a4 89 d0 8b 74 24 02 8b
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler =3D not syncing

If you want the full text of it, its at 67.9.9.32/oops.jpg.

I'm probably just doing something stupid...

On Sat, 2003-08-02 at 15:20, Francois Romieu wrote:
> Justin Sanchez <jsanchez@cs.ucf.edu> :
> [...]
> > How current? I've just seen it in -test2-bk2.
>=20
> Forwarded to davem@redhat.com.
>=20
> You may consider posting the data of the bug-report updated to -test2-bk2
> on netdev@oss.sgi.com.
>=20
> --
> Ueimor
>=20


--=-2Y8LE63gCCNUG9OvqJTX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/LKLaiLmb/rWLQdQRAmWuAJ4g7wXLF1O+gFi+jrLeThezwWAsywCgkiao
YUjA6YtWFR9yOVO/5JnRKZc=
=6zEM
-----END PGP SIGNATURE-----

--=-2Y8LE63gCCNUG9OvqJTX--
