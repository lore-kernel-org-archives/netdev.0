From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] net: socket: fixed coding style issues.
Date: Mon, 11 Jun 2012 21:03:02 +0300
Message-ID: <CAEnQRZDdtGwMKDurKbriAuT5=J0bydEVyeo5sU3u=mvQRa5bTA@mail.gmail.com>
References: <1339420656-11512-1-git-send-email-shaw500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@emloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matthew Shaw <shaw500@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339420656-11512-1-git-send-email-shaw500@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 11, 2012 at 4:17 PM, Matthew Shaw <shaw500@gmail.com> wrote=
:
> Fixed an instance where brances are used but not needed, and some lin=
es
> in the comments and code that exceed the 80 character limit.
>
> Signed-off-by: Matthew Shaw <shaw500@gmail.com>
> ---
> =A0net/socket.c | =A0137 ++++++++++++++++++++++++++++++++------------=
--------------
> =A01 file changed, 75 insertions(+), 62 deletions(-)
>
> diff --git a/net/socket.c b/net/socket.c
> index 6e0ccc0..2133040 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -8,48 +8,48 @@
> =A0* =A0 =A0 =A0 =A0 =A0 =A0 Fred N. van Kempen, <waltje@uWalt.NL.Mug=
net.ORG>
> =A0*
> =A0* Fixes:
> - * =A0 =A0 =A0 =A0 =A0 =A0 Anonymous =A0 =A0 =A0 : =A0 =A0 =A0 NOTSO=
CK/BADF cleanup. Error fix in
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 shutdown()
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 ver=
ify_area() fixes
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Rem=
oved DDI
> - * =A0 =A0 =A0 =A0 =A0 =A0 Jonathan Kamens : =A0 =A0 =A0 SOCK_DGRAM =
reconnect bug
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Mov=
ed a load of checks to the very
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 top level.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Mov=
e address structures to/from user
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 mode above the protocol layers.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Rob Janssen =A0 =A0 : =A0 =A0 =A0 Allow 0=
 length sends.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Asy=
nchronous I/O support (cribbed from the
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 tty drivers).
> - * =A0 =A0 =A0 =A0 =A0 =A0 Niibe Yutaka =A0 =A0: =A0 =A0 =A0 Asynchr=
onous I/O for writes (4.4BSD style)
> - * =A0 =A0 =A0 =A0 =A0 =A0 Jeff Uphoff =A0 =A0 : =A0 =A0 =A0 Made ma=
x number of sockets command-line
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 configurable.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Matti Aarnio =A0 =A0: =A0 =A0 =A0 Made th=
e number of sockets dynamic,
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 to be allocated when needed, and mr.
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 Uphoff's max is used as max to be
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 allowed to allocate.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Linus =A0 =A0 =A0 =A0 =A0 : =A0 =A0 =A0 A=
rgh. removed all the socket allocation
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 altogether: it's in the inode now.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Mad=
e sock_alloc()/sock_release() public
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 for NetROM and future kernel nfsd type
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 stuff.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 sen=
dmsg/recvmsg basics.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Tom Dyas =A0 =A0 =A0 =A0: =A0 =A0 =A0 Exp=
ort net symbols.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Marcin Dalecki =A0: =A0 =A0 =A0 Fixed pro=
blems with CONFIG_NET=3D"n".
> - * =A0 =A0 =A0 =A0 =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Add=
ed thread locking to sys_* calls
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 for sockets. May have errors at the
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 moment.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Kevin Buhr =A0 =A0 =A0: =A0 =A0 =A0 Fixed=
 the dumb errors in the above.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Andi Kleen =A0 =A0 =A0: =A0 =A0 =A0 Some =
small cleanups, optimizations,
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 and fixed a copy_from_user() bug.
> - * =A0 =A0 =A0 =A0 =A0 =A0 Tigran Aivazian : =A0 =A0 =A0 sys_send(ar=
gs) calls sys_sendto(args, NULL, 0)
> - * =A0 =A0 =A0 =A0 =A0 =A0 Tigran Aivazian : =A0 =A0 =A0 Made listen=
(2) backlog sanity checks
> - * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 protocol-independent
> + * =A0 =A0 Anonymous =A0 =A0 =A0 : =A0 =A0 =A0 NOTSOCK/BADF cleanup.=
 Error fix in
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shutdown(=
)
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 verify_area() fixes
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Removed DDI
> + * =A0 =A0 Jonathan Kamens : =A0 =A0 =A0 SOCK_DGRAM reconnect bug
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Moved a load of che=
cks to the very
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 top level=
=2E
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Move address struct=
ures to/from user
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mode abov=
e the protocol layers.
> + * =A0 =A0 Rob Janssen =A0 =A0 : =A0 =A0 =A0 Allow 0 length sends.
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Asynchronous I/O su=
pport (cribbed from the
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tty drive=
rs).
> + * =A0 =A0 Niibe Yutaka =A0 =A0: =A0 =A0 =A0 Asynchronous I/O for wr=
ites (4.4BSD style)
> + * =A0 =A0 Jeff Uphoff =A0 =A0 : =A0 =A0 =A0 Made max number of sock=
ets command-line
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 configura=
ble.
> + * =A0 =A0 Matti Aarnio =A0 =A0: =A0 =A0 =A0 Made the number of sock=
ets dynamic,
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 to be all=
ocated when needed, and mr.
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Uphoff's =
max is used as max to be
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 allowed t=
o allocate.
> + * =A0 =A0 Linus =A0 =A0 =A0 =A0 =A0 : =A0 =A0 =A0 Argh. removed all=
 the socket allocation
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 altogethe=
r: it's in the inode now.
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Made sock_alloc()/s=
ock_release() public
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for NetRO=
M and future kernel nfsd type
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stuff.
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 sendmsg/recvmsg bas=
ics.
> + * =A0 =A0 Tom Dyas =A0 =A0 =A0 =A0: =A0 =A0 =A0 Export net symbols.
> + * =A0 =A0 Marcin Dalecki =A0: =A0 =A0 =A0 Fixed problems with CONFI=
G_NET=3D"n".
> + * =A0 =A0 Alan Cox =A0 =A0 =A0 =A0: =A0 =A0 =A0 Added thread lockin=
g to sys_* calls
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for socke=
ts. May have errors at the
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 moment.
> + * =A0 =A0 Kevin Buhr =A0 =A0 =A0: =A0 =A0 =A0 Fixed the dumb errors=
 in the above.
> + * =A0 =A0 Andi Kleen =A0 =A0 =A0: =A0 =A0 =A0 Some small cleanups, =
optimizations,
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 and fixed=
 a copy_from_user() bug.
> + * =A0 =A0 Tigran Aivazian : =A0 =A0 =A0 sys_send(args) calls sys_se=
ndto(args, NULL, 0)
> + * =A0 =A0 Tigran Aivazian : =A0 =A0 =A0 Made listen(2) backlog sani=
ty checks
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 protocol-=
independent
> =A0*
> =A0*
> - * =A0 =A0 =A0 =A0 =A0 =A0 This program is free software; you can re=
distribute it and/or
> - * =A0 =A0 =A0 =A0 =A0 =A0 modify it under the terms of the GNU Gene=
ral Public License
> - * =A0 =A0 =A0 =A0 =A0 =A0 as published by the Free Software Foundat=
ion; either version
> - * =A0 =A0 =A0 =A0 =A0 =A0 2 of the License, or (at your option) any=
 later version.
> + * =A0 =A0 This program is free software; you can redistribute it an=
d/or
> + * =A0 =A0 modify it under the terms of the GNU General Public Licen=
se
> + * =A0 =A0 as published by the Free Software Foundation; either vers=
ion
> + * =A0 =A0 2 of the License, or (at your option) any later version.
> =A0*
> =A0*
> =A0* =A0 =A0 This module is effectively the top level interface to th=
e BSD socket
> @@ -128,8 +128,9 @@ static ssize_t sock_splice_read(struct file *file=
, loff_t *ppos,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsign=
ed int flags);
>
> =A0/*
> - * =A0 =A0 Socket files have a set of 'special' operations as well a=
s the generic file ones. These don't appear
> - * =A0 =A0 in the operation structures but are done directly via the=
 socketcall() multiplexor.
> + * =A0 =A0 Socket files have a set of 'special' operations as well a=
s the generic
> + * =A0 =A0 =A0file ones. These don't appear in the operation structu=
res but are done
> + * =A0 =A0 =A0directly via the socketcall() multiplexor.
> =A0*/
>
> =A0static const struct file_operations socket_file_ops =3D {
> @@ -181,7 +182,8 @@ static DEFINE_PER_CPU(int, sockets_in_use);
> =A0* =A0 =A0 invalid addresses -EFAULT is returned. On a success 0 is=
 returned.
> =A0*/
>
> -int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockadd=
r_storage *kaddr)
> +int move_addr_to_kernel(void __user *uaddr, int ulen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sockaddr_storage=
 *kaddr)
> =A0{
> =A0 =A0 =A0 =A0if (ulen < 0 || ulen > sizeof(struct sockaddr_storage)=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -584,7 +586,8 @@ int sock_sendmsg(struct socket *sock, struct msgh=
dr *msg, size_t size)
> =A0}
> =A0EXPORT_SYMBOL(sock_sendmsg);
>
> -static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *ms=
g, size_t size)
> +static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *ms=
g,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size=
)
> =A0{
> =A0 =A0 =A0 =A0struct kiocb iocb;
> =A0 =A0 =A0 =A0struct sock_iocb siocb;
> @@ -711,7 +714,8 @@ void __sock_recv_ts_and_drops(struct msghdr *msg,=
 struct sock *sk,
> =A0EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
>
> =A0static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct =
socket *sock,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct msghdr *msg, size_t size, int flags)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct msghdr *msg, size_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0int flags)
> =A0{
> =A0 =A0 =A0 =A0struct sock_iocb *si =3D kiocb_to_siocb(iocb);
>
> @@ -1158,7 +1162,9 @@ static int sock_fasync(int fd, struct file *fil=
p, int on)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -/* This function may be called only under socket lock or callback_lo=
ck or rcu_lock */
> +/* This function may be called only under socket lock or callback_lo=
ck
> + * or rcu_lock.
> + */
>
> =A0int sock_wake_async(struct socket *sock, int how, int band)
> =A0{
> @@ -1229,8 +1235,8 @@ int __sock_create(struct net *net, int family, =
int type, int protocol,
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0Allocate the socket and allow the family=
 to set things up. if
> - =A0 =A0 =A0 =A0* =A0 =A0 =A0the protocol is 0, the family is instru=
cted to select an appropriate
> - =A0 =A0 =A0 =A0* =A0 =A0 =A0default.
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0the protocol is 0, the family is instru=
cted to select an
> + =A0 =A0 =A0 =A0* =A0 =A0 =A0appropriate default.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0sock =3D sock_alloc();
> =A0 =A0 =A0 =A0if (!sock) {
> @@ -1308,7 +1314,8 @@ EXPORT_SYMBOL(__sock_create);
>
> =A0int sock_create(int family, int type, int protocol, struct socket =
**res)
> =A0{
> - =A0 =A0 =A0 return __sock_create(current->nsproxy->net_ns, family, =
type, protocol, res, 0);
> + =A0 =A0 =A0 return __sock_create(current->nsproxy->net_ns, family, =
type, protocol,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res, 0);
> =A0}
> =A0EXPORT_SYMBOL(sock_create);
>
> @@ -1928,9 +1935,9 @@ static int __sys_sendmsg(struct socket *sock, s=
truct msghdr __user *msg,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* This will also move the address data into kernel sp=
ace */
> - =A0 =A0 =A0 if (MSG_CMSG_COMPAT & flags) {
> + =A0 =A0 =A0 if (MSG_CMSG_COMPAT & flags)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D verify_compat_iovec(msg_sys, i=
ov, &address, VERIFY_READ);
> - =A0 =A0 =A0 } else
> + =A0 =A0 =A0 else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D verify_iovec(msg_sys, iov, &ad=
dress, VERIFY_READ);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> @@ -1957,9 +1964,9 @@ static int __sys_sendmsg(struct socket *sock, s=
truct msghdr __user *msg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EFAULT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Careful! Before this, msg_sys->msg=
_control contains a user pointer.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Afterwards, it will be a kernel po=
inter. Thus the compiler-assisted
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* checking falls down on this.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Careful! Before this, msg_sys->msg=
_control contains a user
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pointer. Afterwards, it will be a =
kernel pointer. Thus the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* compiler-assisted checking falls d=
own on this.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (copy_from_user(ctl_buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
void __user __force *)msg_sys->msg_control,
> @@ -2010,7 +2017,8 @@ out:
> =A0* =A0 =A0 BSD sendmsg interface
> =A0*/
>
> -SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsig=
ned int, flags)
> +SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsig=
ned int,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags)
> =A0{
> =A0 =A0 =A0 =A0int fput_needed, err;
> =A0 =A0 =A0 =A0struct msghdr msg_sys;
> @@ -2056,7 +2064,8 @@ int __sys_sendmmsg(int fd, struct mmsghdr __use=
r *mmsg, unsigned int vlen,
>
> =A0 =A0 =A0 =A0while (datagrams < vlen) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (MSG_CMSG_COMPAT & flags) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __sys_sendmsg(s=
ock, (struct msghdr __user *)compat_entry,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __sys_sendmsg(s=
ock,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(struct msghdr __user *)compat_entry,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0&msg_sys, flags, &used_address);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -2132,9 +2141,9 @@ static int __sys_recvmsg(struct socket *sock, s=
truct msghdr __user *msg,
>
> =A0 =A0 =A0 =A0uaddr =3D (__force void __user *)msg_sys->msg_name;
> =A0 =A0 =A0 =A0uaddr_len =3D COMPAT_NAMELEN(msg);
> - =A0 =A0 =A0 if (MSG_CMSG_COMPAT & flags) {
> + =A0 =A0 =A0 if (MSG_CMSG_COMPAT & flags)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D verify_compat_iovec(msg_sys, i=
ov, &addr, VERIFY_WRITE);
> - =A0 =A0 =A0 } else
> + =A0 =A0 =A0 else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D verify_iovec(msg_sys, iov, &ad=
dr, VERIFY_WRITE);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> @@ -2661,13 +2670,15 @@ static int dev_ifconf(struct net *net, struct=
 compat_ifconf __user *uifc32)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ifc.ifc_req =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uifc =3D compat_alloc_user_space(sizeo=
f(struct ifconf));
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D ((ifc32.ifc_len / sizeof=
(struct compat_ifreq)) + 1) *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D ((ifc32.ifc_len /
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct compat_if=
req)) + 1) *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(struct ifreq);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uifc =3D compat_alloc_user_space(sizeo=
f(struct ifconf) + len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ifc.ifc_len =3D len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ifr =3D ifc.ifc_req =3D (void __user *=
)(uifc + 1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ifr32 =3D compat_ptr(ifc32.ifcbuf);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < ifc32.ifc_len; i +=3D=
 sizeof(struct compat_ifreq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < ifc32.ifc_len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0i +=3D sizeof(struct compat_=
ifreq)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (copy_in_user(ifr, =
ifr32, sizeof(struct compat_ifreq)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EFAULT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ifr++;
> @@ -2832,7 +2843,8 @@ static int ethtool_ioctl(struct net *net, struc=
t compat_ifreq __user *ifr32)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int compat_siocwandev(struct net *net, struct compat_ifreq __=
user *uifr32)
> +static int compat_siocwandev(struct net *net,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct compa=
t_ifreq __user *uifr32)
> =A0{
> =A0 =A0 =A0 =A0void __user *uptr;
> =A0 =A0 =A0 =A0compat_uptr_t uptr32;
> @@ -3000,7 +3012,8 @@ static int compat_sioc_ifmap(struct net *net, u=
nsigned int cmd,
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> -static int compat_siocshwtstamp(struct net *net, struct compat_ifreq=
 __user *uifr32)
> +static int compat_siocshwtstamp(struct net *net,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
compat_ifreq __user *uifr32)

I think that going over the 80 chars limit is acceptable in this kind
of situations. The code
looks ugly with the new formatting.

> =A0{
> =A0 =A0 =A0 =A0void __user *uptr;
> =A0 =A0 =A0 =A0compat_uptr_t uptr32;
> --
> 1.7.9.5

thanks,
Daniel.
