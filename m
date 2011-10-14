From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Fri, 14 Oct 2011 16:57:46 +0200
Message-ID: <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Elmar Vonlanthen <evonlanthen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 14 octobre 2011 =C3=A0 10:08 +0200, Elmar Vonlanthen a =C3=A9=
crit :
> Hello again
>=20
> Kernel 3.0.6 is affected as well.
>=20
> 2011-10-14 09:50:46 chgut11fw01 kernel: skb_over_panic: text:c13059c9
> len:64 put:64 head:c730c400 data:c730c450 tail:0xc730c490
> end:0xc730c480 dev:<NULL>
> 2011-10-14 09:50:46 chgut11fw01 kernel: ------------[ cut here ]-----=
-------
> 2011-10-14 09:50:46 chgut11fw01 kernel: kernel BUG at net/core/skbuff=
=2Ec:128!
> 2011-10-14 09:50:46 chgut11fw01 kernel: invalid opcode: 0000 [#1] SMP
> 2011-10-14 09:50:46 chgut11fw01 kernel: Modules linked in: ip_gre gre
> authenc xfrm4_mode_transport deflate zlib_deflate ctr twofish_generic
> twofish_common serpent cryptd aes_i586 aes_generic blowfish cast5 cbc
> ecb rmd160 sha512_generic sha256_generic sha1_generic xfrm_user
> xfrm4_tunnel tunnel4 ipcomp xfrm_ipcomp esp4 ah4 af_key tun ipt_LOG
> xt_limit ipt_REJECT xt_state ipt_REDIRECT ipt_MASQUERADE xt_policy
> xt_TCPMSS xt_tcpmss xt_tcpudp xt_NOTRACK iptable_filter iptable_nat
> xt_mark xt_connmark iptable_mangle iptable_raw ip_tables x_tables
> nf_conntrack_tftp nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
> nf_conntrack_ftp nf_conntrack rtc ppdev parport_pc parport w83792d
> i2c_dev i2c_i801 i2c_core pl2303 usbserial coretemp hwmon usbhid
> ohci_hcd uhci_hcd ehci_hcd usbcore e1000 e1000e aufs ata_piix libata
> 2011-10-14 09:50:46 chgut11fw01 kernel:
> 2011-10-14 09:50:46 chgut11fw01 kernel: Pid: 6299, comm: ospfd Not
> tainted 3.0.6-SMP #1    /LakePort
> 2011-10-14 09:50:46 chgut11fw01 kernel: EIP: 0060:[<c12b6815>] EFLAGS=
:
> 00010292 CPU: 0
> 2011-10-14 09:50:46 chgut11fw01 kernel: EIP is at skb_put+0x85/0x90
> 2011-10-14 09:50:46 chgut11fw01 kernel: EAX: 00000078 EBX: c13059c9
> ECX: 00000096 EDX: ffffff8b
> 2011-10-14 09:50:46 chgut11fw01 kernel: ESI: deac4a80 EDI: 00000040
> EBP: d8979c80 ESP: d8979c58
> 2011-10-14 09:50:46 chgut11fw01 kernel: DS: 007b ES: 007b FS: 00d8 GS=
:
> 0033 SS: 0068
> 2011-10-14 09:50:46 chgut11fw01 kernel: Process ospfd (pid: 6299,
> ti=3Dd8978000 task=3Dde94ee80 task.ti=3Dd8978000)
> 2011-10-14 09:50:46 chgut11fw01 kernel: Stack:
> 2011-10-14 09:50:46 chgut11fw01 kernel: c13fd194 c13059c9 00000040
> 00000040 c730c400 c730c450 c730c490 c730c480
> 2011-10-14 09:50:46 chgut11fw01 kernel: c13fb21c d897da40 d8979d38
> c13059c9 d8979d24 8db04700 00000001 00000001
> 2011-10-14 09:50:46 chgut11fw01 kernel: d8979ce4 d8979cc8 c121ce7d
> 00000000 000012b5 d8979ecc dbff0c00 c730c450
> 2011-10-14 09:50:46 chgut11fw01 kernel: Call Trace:
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c13059c9>] ? raw_sendmsg+0x=
5a9/0x850
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c13059c9>] raw_sendmsg+0x5a=
9/0x850
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c121ce7d>] ? extract_entrop=
y+0x5d/0x70
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c1027f73>] ?
> try_to_wake_up+0x173/0x1f0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b2700>] ? release_sock+0=
xb0/0xd0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c130f222>] inet_sendmsg+0x4=
2/0xa0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c1021407>] ?
> __wake_up_sync_key+0x47/0x60
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12afc07>] sock_sendmsg+0xa=
7/0xd0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b29f3>] ?
> sock_def_readable+0x33/0x60
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12afc07>] ? sock_sendmsg+0=
xa7/0xd0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b8e83>] ? verify_iovec+0=
x53/0xb0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b08e4>] __sys_sendmsg+0x=
2d4/0x2e0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12afc9e>] ?
> sockfd_lookup_light+0x1e/0x70
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b02fa>] ? sys_sendto+0xa=
a/0xe0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c102f928>] ? nsecs_to_jiffi=
es+0x8/0x10
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12eaf11>] ? ip_setsockopt+=
0x41/0xa0
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b0a36>] sys_sendmsg+0x36=
/0x60
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c12b1669>] sys_socketcall+0=
xe9/0x280
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c133d8c5>] syscall_call+0x7=
/0xb
> 2011-10-14 09:50:46 chgut11fw01 kernel: [<c1330000>] ?
> packet_recvmsg+0x170/0x440
> 2011-10-14 09:50:46 chgut11fw01 kernel: Code: 00 00 89 4c 24 14 8b 88
> a4 00 00 00 89 54 24 0c 89 4c 24 10 8b 40 50 89 5c 24 04 c7 04 24 94
> d1 3f c1 89 44 24 08 e8 b4 4b 08 00 <0f> 0b eb fe b9 1c b2 3f c1 eb a=
e
> 55 89 e5 57 56 89 d6 53 89 c3
> 2011-10-14 09:50:46 chgut11fw01 kernel: EIP: [<c12b6815>]
> skb_put+0x85/0x90 SS:ESP 0068:d8979c58
> 2011-10-14 09:50:46 chgut11fw01 kernel: ---[ end trace ff341104610bee=
ed ]---

> Could anyone give me a hint, how I can furher proceed to find the err=
or?
> Thanks.

Please try following patch :

[PATCH] ip_gre: dont increase dev->needed_headroom on a live device

It seems ip_gre is able to change dev->needed_headroom on the fly.

Its is not legal unfortunately and triggers a BUG in raw_sendmsg()

skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.dev)=20

< another cpu change dev->needed_headromm (making it bigger)

=2E..
skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));

We end with LL_RESERVED_SPACE() being bigger than LL_ALLOCATED_SPACE()
-> we crash later because skb head is exhausted.

Bug introduced in commit 243aad83 in 2.6.34 (ip_gre: include route
header_len in max_headroom calculation)

Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Timo Ter=C3=A4s <timo.teras@iki.fi>
CC: Herbert Xu <herbert@gondor.apana.org.au>
---
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8871067..1505dcf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -835,8 +835,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
 		struct sk_buff *new_skb =3D skb_realloc_headroom(skb, max_headroom);
-		if (max_headroom > dev->needed_headroom)
-			dev->needed_headroom =3D max_headroom;
 		if (!new_skb) {
 			ip_rt_put(rt);
 			dev->stats.tx_dropped++;
