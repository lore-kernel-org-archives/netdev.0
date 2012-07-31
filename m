From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [BUG] igb: panic at boot time with latest Linus tree
Date: Mon, 30 Jul 2012 23:26:11 -0700
Message-ID: <1343715971.2230.4.camel@jtkirshe-mobl>
References: <1343715255.21269.47.camel@edumazet-glaptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DKOdBhnjALxGmbu36p/M"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53489 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755266Ab2GaG03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 02:26:29 -0400
In-Reply-To: <1343715255.21269.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DKOdBhnjALxGmbu36p/M
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-31 at 08:14 +0200, Eric Dumazet wrote:
> For information, I get this each time I boot on latest Linus tree :
>=20
> RTNL is left locked, so machine unusable.
>=20
> No problem with David net tree, so thats a bit strange...
>=20
> Not sure I'll have time to investigate today
> (And tomorrow I am off for the day)
>=20
> [   11.153682] BUG: unable to handle kernel NULL pointer dereference at  =
         (null)
> [   11.153806] IP: [<          (null)>]           (null)
> [   11.153872] PGD 310544067 PUD 311b2d067 PMD 0=20
> [   11.153945] Oops: 0010 [#1] SMP=20
> [   11.154012] Modules linked in: nfsd exportfs nfs lockd auth_rpcgss sun=
rpc asix usbnet rt61pci crc_itu_t rt2x00pci rt2x00lib eeprom_93cx6 tg3 ixgb=
e mdio igb
> [   11.154227] CPU 10=20
> [   11.154239] Pid: 2476, comm: NetworkManager Not tainted 3.5.0+ #123 He=
wlett-Packard HP Z600 Workstation/0B54h
> [   11.154437] RIP: 0010:[<0000000000000000>]  [<          (null)>]      =
     (null)
> [   11.154574] RSP: 0018:ffff88030f667630  EFLAGS: 00010282
> [   11.154645] RAX: 0000000017cf7980 RBX: ffff88031080f100 RCX: 000000000=
0000200
> [   11.154720] RDX: 0000000000000040 RSI: ffffea0017cf7980 RDI: ffff88061=
1bc1098
> [   11.154794] RBP: ffff88030f667678 R08: 0000000000000002 R09: 000000000=
0000000
> [   11.154868] R10: ffffea0017cf7980 R11: 0000000000000000 R12: ffffc9000=
7d58000
> [   11.154942] R13: ffff880611bc1098 R14: ffff8803106ff000 R15: ffff8805f=
3de6040
> [   11.155016] FS:  00007fa2e4b94800(0000) GS:ffff88061fc80000(0000) knlG=
S:0000000000000000
> [   11.155148] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   11.155220] CR2: 0000000000000000 CR3: 000000031066a000 CR4: 000000000=
00007e0
> [   11.155283] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> [   11.155347] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
> [   11.155411] Process NetworkManager (pid: 2476, threadinfo ffff88030f66=
6000, task ffff880310dd2d00)
> [   11.155523] Stack:
> [   11.155579]  ffffffffa00071fe 0000000000000000 00ffff00a000400a ffff88=
030f667678
> [   11.155712]  ffff88030f610700 0000000000000001 ffff88030f610708 ffff88=
030f610740
> [   11.155840]  0000000000000001 ffff88030f6676b8 ffffffffa000834b ffff88=
030f610700
> [   11.155969] Call Trace:
> [   11.156036]  [<ffffffffa00071fe>] ? igb_alloc_rx_buffers+0x13e/0x2d0 [=
igb]
> [   11.156104]  [<ffffffffa000834b>] igb_configure+0x34b/0x4d0 [igb]
> [   11.156170]  [<ffffffffa0008572>] __igb_open+0xa2/0x510 [igb]
> [   11.156237]  [<ffffffff812c0731>] ? find_next_bit+0x21/0xd0
> [   11.156303]  [<ffffffffa0008b50>] igb_open+0x10/0x20 [igb]
> [   11.156369]  [<ffffffff8155288f>] __dev_open+0x8f/0xe0
> [   11.156432]  [<ffffffff81552b31>] __dev_change_flags+0xa1/0x180
> [   11.156495]  [<ffffffff81552cc8>] dev_change_flags+0x28/0x70
> [   11.156559]  [<ffffffff8155f664>] do_setlink+0x284/0x9e0
> [   11.156624]  [<ffffffff81560c8a>] ? rtnl_fill_ifinfo+0x92a/0xb30
> [   11.156690]  [<ffffffff812cc220>] ? nla_parse+0x30/0xe0
> [   11.156755]  [<ffffffff81561b35>] rtnl_newlink+0x345/0x580
> [   11.156820]  [<ffffffff812655b9>] ? selinux_capable+0x39/0x50
> [   11.156885]  [<ffffffff81262538>] ? security_capable+0x18/0x20
> [   11.156948]  [<ffffffff81561384>] rtnetlink_rcv_msg+0x124/0x310
> [   11.157012]  [<ffffffff8113794b>] ? kfree+0x3b/0x160
> [   11.157074]  [<ffffffff81561260>] ? __rtnl_unlock+0x20/0x20
> [   11.157137]  [<ffffffff8157a569>] netlink_rcv_skb+0xa9/0xd0
> [   11.157200]  [<ffffffff8155ed55>] rtnetlink_rcv+0x25/0x40
> [   11.157262]  [<ffffffff81579f4d>] netlink_unicast+0x1ad/0x230
> [   11.157326]  [<ffffffff8157a286>] netlink_sendmsg+0x2b6/0x310
> [   11.157396]  [<ffffffff815381ac>] sock_sendmsg+0xdc/0xf0
> [   11.157459]  [<ffffffff8153aab8>] ? move_addr_to_kernel+0x68/0xb0
> [   11.157526]  [<ffffffff81539b12>] __sys_sendmsg+0x392/0x3a0
> [   11.157590]  [<ffffffff81118bbe>] ? handle_mm_fault+0x13e/0x210
> [   11.157656]  [<ffffffff81155008>] ? __d_free+0x48/0x70
> [   11.157720]  [<ffffffff8115e616>] ? mntput+0x26/0x40
> [   11.157783]  [<ffffffff81140371>] ? __fput+0x191/0x250
> [   11.157846]  [<ffffffff8153b809>] sys_sendmsg+0x49/0x90
> [   11.157911]  [<ffffffff816ca652>] system_call_fastpath+0x16/0x1b
> [   11.157973] Code:  Bad RIP value.
> [   11.158041] RIP  [<          (null)>]           (null)
> [   11.158106]  RSP <ffff88030f667630>
> [   11.158163] CR2: 0000000000000000
> [   11.158227] ---[ end trace bbfaed088efd61cb ]---
> [   11.158300] NetworkManager (2476) used greatest stack depth: 2936 byte=
s left
>=20
>=20

I have an igb patch current in test to fix a panic in igb.  Here is the
patch:

From: Emil Tantilov <emil.s.tantilov@intel.com>
Subject: igb: fix panic while dumping packets on Tx hang with IOMMU

This patch resolves a "BUG: unable to handle kernel paging request
at ..." oops while dumping packet data. The issue occurs with IOMMU
enabled due to the address provided by phys_to_virt().

This patch avoids phys_to_virt() by making using skb->data and the
address of the pages allocated for Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>

---
drivers/net/ethernet/intel/igb/igb_main.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
b/drivers/net/ethernet/intel/igb/igb_main.c
index 447e131..8d7e5da 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -462,10 +462,10 @@ static void igb_dump(struct igb_adapter *adapter)
                                (u64)buffer_info->time_stamp,
                                buffer_info->skb, next_desc);

-                       if (netif_msg_pktdata(adapter) &&
buffer_info->dma !=3D 0)
+                       if (netif_msg_pktdata(adapter) &&
buffer_info->skb)
                                print_hex_dump(KERN_INFO, "",
                                        DUMP_PREFIX_ADDRESS,
-                                       16, 1,
phys_to_virt(buffer_info->dma),
+                                       16, 1, buffer_info->skb->data,
                                        buffer_info->length, true);
                }
        }
@@ -547,18 +547,17 @@ rx_ring_summary:
                                        (u64)buffer_info->dma,
                                        buffer_info->skb, next_desc);

-                               if (netif_msg_pktdata(adapter)) {
+                               if (netif_msg_pktdata(adapter) &&
+                                   buffer_info->dma &&
buffer_info->skb) {
                                        print_hex_dump(KERN_INFO, "",
-                                               DUMP_PREFIX_ADDRESS,
-                                               16, 1,
-
phys_to_virt(buffer_info->dma),
-                                               IGB_RX_HDR_LEN, true);
+                                                 DUMP_PREFIX_ADDRESS,
+                                                 16, 1,
buffer_info->skb->data,
+                                                 IGB_RX_HDR_LEN, true);
                                        print_hex_dump(KERN_INFO, "",
                                          DUMP_PREFIX_ADDRESS,
                                          16, 1,
-                                         phys_to_virt(
-                                           buffer_info->page_dma +
-                                           buffer_info->page_offset),
+
page_address(buffer_info->page) +
+
buffer_info->page_offset,
                                          PAGE_SIZE/2, true);
                                }
                        }


--=-DKOdBhnjALxGmbu36p/M
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQF3qDAAoJEOVv75VaS+3ODNEQAKYRIzxm3PyuageX5upf4ts4
EfRQAFx6094ERJhwnLflI3SJ1FaK9IGYZa5RRURx5/tuhnt8e9H50ISN7yRyfFnO
K2u6uaq6c5DzTnP7S5+i/y3w6tREI45XzBUJHhPWZU4ZZ0M7jtVtGvzzLDOv5gP5
lXJWTHdab3VURNc41NXxWZitaYXU5Rl+BfCjeEh8RhsI/sOkzFtwnDwKA9nFofpU
B2qptyM+6i7lG02xhNEVmkUAjqZs46cod8WiAvpzif9jVQB/JZJ8hk4eb8w+5hJB
V7EPitT0aXsQdRy7xXjX3yiaG2/0Y/vZYaUgTr50M4klw3QMCAC1J5BABtO//QdM
W81o/Myui/J55KcqdIKdul0qO3KZXUwT1A2uHkA2JaZ1/apnFnx+3NNktT9h+IFV
QlayBDV5XuWrixHOKplgS4Droovq3VPZext+goI/xmHYaEHtiGtrxb3VzafU3+h+
fWEJ09Xd4+RS76/7mnhlJegYU4P5U4/K4EKgFSUEdqqW+shlYSkINEb4tifs60VP
kg5/9U2qmQhQeMkgWF0wy1R1bNEKN+4WDAqv97BTgKnShlhOapCGHy12RRJ7LYLo
8X+AL1SqT8d940BhWqrw7SSq9WqUS9Db59jK75d84EFHEd7M7NJvTLVfe4LXyahE
LwTpySO7X32HtFZ1loDP
=EAOL
-----END PGP SIGNATURE-----

--=-DKOdBhnjALxGmbu36p/M--
