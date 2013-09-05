From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60853] New: OOPS at find_appropriate_src+0xdb/0x1a0
 [nf_nat]
Date: Thu, 5 Sep 2013 08:04:54 -0700
Message-ID: <20130905080454.485fedae@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61004 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab3IEPE5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 11:04:57 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so2017218pab.41
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 08:04:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 4 Sep 2013 20:02:15 -0700
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60853] New: OOPS at find_appropriate_src+0xdb/0x1a0 [nf_n=
at]


https://bugzilla.kernel.org/show_bug.cgi?id=3D60853

            Bug ID: 60853
           Summary: OOPS at find_appropriate_src+0xdb/0x1a0 [nf_nat]
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.43-0.4-default
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: lizhao09@huawei.com
        Regression: No

[10542399.515396] BUG: unable to handle kernel NULL pointer dereference=
 at
000000000000003e
[10542399.523469] IP: [<ffffffffa1491a4b>] find_appropriate_src+0xdb/0x=
1a0
[nf_nat]
[10542399.530843] PGD 17f55ec067 PUD 17fba37067 PMD 0
[10542399.535727] Oops: 0000 [#1] SMP
[10542399.539220] last sysfs file:
/sys/devices/system/cpu/cpu23/cache/index2/shared_cpu_map
[10542399.547355] CPU 8
[10542399.647544] Supported: Yes, External
[10542399.651361] Pid: 0, comm: swapper Tainted: P          NX
2.6.32.43-0.4-default #1 Thurley
[10542399.659755] RIP: 0010:[<ffffffffa1491a4b>]  [<ffffffffa1491a4b>]
find_appropriate_src+0xdb/0x1a0 [nf_nat]
[10542399.669552] RSP: 0018:ffff88002c3039f0  EFLAGS: 00010286
[10542399.675095] RAX: 0000000000000000 RBX: ffff8817814beb90 RCX:
0000000024852261
[10542399.682454] RDX: 0000000000000000 RSI: 00000000327c4d71 RDI:
ffffffff81cd4dc0
[10542399.689812] RBP: ffff88002c303ad0 R08: 0000000000000011 R09:
0000000000000002
[10542399.697170] R10: 0000000000004000 R11: ffffffffa14726e0 R12:
ffff88002c303aa0
[10542399.704529] R13: ffff88002c303b40 R14: ffff88002c303b4c R15:
ffff88002c303b4e
[10542399.711888] FS:  0000000000000000(0000) GS:ffff88002c300000(0000)
knlGS:0000000000000000
[10542399.720199] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[10542399.726175] CR2: 000000000000003e CR3: 00000017f67f1000 CR4:
00000000000006e0
[10542399.733534] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[10542399.740893] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[10542399.748254] Process swapper (pid: 0, threadinfo ffff881810db2000,=
 task
ffff881810db0080)
[10542399.756560] Stack:
[10542399.758821]  00000000ffffffff ffff88002c303aa0 ffff88002c303ad0
ffff88002c303b40
[10542399.766301] <0> 0000000000000000 ffff8817f7d639e8 000000000000010=
0
ffffffffa1491beb
[10542399.774237] <0> ffff88002c303ad0 ffff8817f7d639e8 ffff88002c303b4=
0
ffff88002c303aa0
[10542399.782365] Call Trace:
[10542399.785085]  [<ffffffffa1491beb>] get_unique_tuple+0xdb/0x240 [nf=
_nat]
[10542399.791847]  [<ffffffffa1491de9>] nf_nat_setup_info+0x99/0x350 [n=
f_nat]
[10542399.798697]  [<ffffffffa149e162>] alloc_null_binding+0x52/0x90
[iptable_nat]
[10542399.805977]  [<ffffffffa149e519>] nf_nat_fn+0x1e9/0x280 [iptable_=
nat]
[10542399.812654]  [<ffffffff81318d18>] nf_iterate+0x68/0xa0
[10542399.818031]  [<ffffffff81318db2>] nf_hook_slow+0x62/0xf0
[10542399.823582]  [<ffffffff813214a1>] ip_local_deliver+0x51/0x80
[10542399.829477]  [<ffffffff81320a59>] ip_rcv_finish+0x1b9/0x440
[10542399.835288]  [<ffffffff812f5f89>] netif_receive_skb+0x599/0x6a0
[10542399.841454]  [<ffffffffa0ea4837>] ixgbe_clean_rx_irq+0x3d7/0xe50 =
[ixgbe]
[10542399.848397]  [<ffffffffa0ea53e4>] ixgbe_clean_rxtx_many+0x134/0x2=
70
[ixgbe]
[10542399.855595]  [<ffffffff812f6863>] net_rx_action+0xe3/0x1a0
[10542399.861318]  [<ffffffff810533ef>] __do_softirq+0xbf/0x170
[10542399.866956]  [<ffffffff810040bc>] call_softirq+0x1c/0x30
[10542399.872506]  [<ffffffff81005cfd>] do_softirq+0x4d/0x80
[10542399.877883]  [<ffffffff81053275>] irq_exit+0x85/0x90
[10542399.883087]  [<ffffffff8100525e>] do_IRQ+0x6e/0xe0
[10542399.888120]  [<ffffffff81003913>] ret_from_intr+0x0/0xa
[10542399.893582]  [<ffffffff8100ae42>] mwait_idle+0x62/0x70
[10542399.898957]  [<ffffffff8100204a>] cpu_idle+0x5a/0xb0
[10542399.904159] Code: 00 00 00 4d 8d 7d 0e 4d 8d 75 0c 48 89 c3 eb 14=
 48 8b
03 48 85 c0 0f 84 84 00 00 00 44 0f b6 45 26 48 89 c3 48 8b 53 20 48 8b=
 03 <44>
38 42 3e 0f 18 08 75 dc 8b 42 18 3b 45 00 75 d4 0f b7 42 28

=46rom the vmcore,we found that:=20

1 OOPS occured at the statement 't->dst.protonum =3D=3D tuple->dst.prot=
onum' in
inline function same_src.=20

2 The first parameter of same_src "ct" is NULL,The value of 'ct' came f=
rom 'ct
=3D nat->ct'.

3 Read the content of the 'nat', all member's value are zero.


static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
{
    struct nf_conn_nat *nat =3D nf_ct_ext_find(ct, NF_CT_EXT_NAT);

    if (nat =3D=3D NULL || nat->ct =3D=3D NULL)
        return;

    NF_CT_ASSERT(nat->ct->status & IPS_NAT_DONE_MASK);

    spin_lock_bh(&nf_nat_lock);
    hlist_del_rcu(&nat->bysource);=20
    spin_unlock_bh(&nf_nat_lock);
}

void nf_conntrack_free(struct nf_conn *ct)
{
  struct net *net =3D nf_ct_net(ct);
  nf_ct_ext_destroy(ct); //For NAT=EF=BC=8Cit will call nf_nat_cleanup_=
conntrack
  atomic_dec(&net->ct.count);   =20
  nf_ct_ext_free(ct);  // Free nat-extention memory by kfree; is it pos=
sible
that the extention was still used in a RCU read side ?
  kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
}

--=20
You are receiving this mail because:
You are the assignee for the bug.
