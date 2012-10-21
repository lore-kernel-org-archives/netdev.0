From: Bernard f6bvp <f6bvp@free.fr>
Subject: [NetRom] possible circular locking dependency detected
Date: Sun, 21 Oct 2012 17:18:58 +0200
Message-ID: <50841262.4020704@free.fr>
References: <4B2CD772.1030106@upmc.fr> <201106171536.15660.arnd@arndb.de> <20110617135147.GA3470@linux-mips.org> <201106171611.10655.arnd@arndb.de> <4E06040B.7040309@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020702000803080705030904"
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org, Bernard Pidoux <bernard.pidoux@free.fr>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4E06040B.7040309@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020702000803080705030904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

When shutting down my dual core system, there was a possible circular 
locking dependency detected that is related to NetRom.

Here is the syslog report.

Regards,

Bernard, f6bvp







--------------020702000803080705030904
Content-Type: text/plain; charset=windows-1252;
 name="ax25ipd_not_tainted.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="ax25ipd_not_tainted.txt"


Oct 21 12:10:35 f6bvp-8 aprslist[1773]: terminating on SIGTERM
Oct 21 12:10:35 f6bvp-8 fpacstat: terminating on SIGTERM
Oct 21 12:10:35 f6bvp-8 netromd[1653]: terminating on SIGTERM
Oct 21 12:10:35 f6bvp-8 ax25ipd: 
Oct 21 12:10:35 f6bvp-8 ax25ipd:   socket     udp on port 10094
Oct 21 12:10:35 f6bvp-8 ax25ipd:   mode       tnc
Oct 21 12:10:35 f6bvp-8 ax25ipd:   device     /dev/ptmx
Oct 21 12:10:35 f6bvp-8 ax25ipd:   speed      115200
Oct 21 12:10:35 f6bvp-8 ax25ipd:   loglevel   1
Oct 21 12:10:35 f6bvp-8 ax25ipd: 
Oct 21 12:10:35 f6bvp-8 ax25ipd:   K4GBB 184.4.148.122 udp 10094 1
Oct 21 12:10:35 f6bvp-8 ax25ipd:   F8COJ 0.0.0.0 udp 10093 1
Oct 21 12:10:35 f6bvp-8 ax25ipd:   F3KT 62.147.189.164 udp 10093 1
Oct 21 12:10:35 f6bvp-8 ax25ipd:   F6BVP-12 192.168.0.68 udp 10093 4
Oct 21 12:10:35 f6bvp-8 ax25ipd:   F6BVP-11 192.168.0.115 udp 10093 4
Oct 21 12:10:35 f6bvp-8 ax25ipd:   F6BVP-10 192.168.0.115 udp 10093 5
Oct 21 12:10:35 f6bvp-8 ax25ipd:   VA2BBS 24.212.252.110 udp 10093 1
Oct 21 12:10:35 f6bvp-8 ax25ipd:   ON4HU 81.243.88.115 udp 10093 1
Oct 21 12:10:35 f6bvp-8 ax25ipd:   IZ3LSV 88.149.155.158 udp 10094 5
Oct 21 12:10:35 f6bvp-8 ax25ipd: 
Oct 21 12:10:35 f6bvp-8 nfs-server[27474]: Arrêt de NFS kernel daemon
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150299] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150313] ======================================================
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150317] [ INFO: possible circular locking dependency detected ]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150321] 3.6.1 #1 Not tainted
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150325] -------------------------------------------------------
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150329] ax25ipd/1580 is trying to acquire lock:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150333]  (nr_node_list_lock){+.....}, at: [<ffffffffa06775ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150352] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150352] but task is already holding lock:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150356]  (nr_neigh_list_lock){+.-.-.}, at: [<ffffffffa0677596>] nr_rt_device_down+0x26/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150373] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150373] which lock already depends on the new lock.
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150373] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150378] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150378] the existing dependency chain (in reverse order) is:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150382] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150382] -> #2 (nr_neigh_list_lock){+.-.-.}:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150396]        [<ffffffff810b6452>] lock_acquire+0x92/0x120
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150409]        [<ffffffff81482b76>] _raw_spin_lock_bh+0x36/0x50
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150418]        [<ffffffffa06769eb>] nr_remove_neigh+0x1b/0xb0 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150429]        [<ffffffffa0677c20>] nr_rt_ioctl+0x2b0/0xa60 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150438]        [<ffffffffa0673fa1>] nr_ioctl+0x51/0x1d0 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150445]        [<ffffffff813973e0>] sock_do_ioctl+0x30/0x70
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150454]        [<ffffffff813976f9>] sock_ioctl+0x79/0x2f0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150460]        [<ffffffff8118dd08>] do_vfs_ioctl+0x98/0x560
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150468]        [<ffffffff8118e261>] sys_ioctl+0x91/0xa0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150477]        [<ffffffff8148b6b9>] system_call_fastpath+0x16/0x1b
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150486] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150486] -> #1 (&(&nr_node->node_lock)->rlock){+.....}:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150498]        [<ffffffff810b6452>] lock_acquire+0x92/0x120
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150505]        [<ffffffff81482b76>] _raw_spin_lock_bh+0x36/0x50
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150512]        [<ffffffffa0676acc>] nr_node_show+0x4c/0x150 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150522]        [<ffffffff8119da5c>] seq_read+0x26c/0x420
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150529]        [<ffffffff811e1046>] proc_reg_read+0x86/0xc0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150537]        [<ffffffff8117b01c>] vfs_read+0xac/0x180
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150546]        [<ffffffff8117b13a>] sys_read+0x4a/0x90
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150552]        [<ffffffff8148b6b9>] system_call_fastpath+0x16/0x1b
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150559] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150559] -> #0 (nr_node_list_lock){+.....}:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150571]        [<ffffffff810b5c41>] __lock_acquire+0x1a91/0x1ce0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150578]        [<ffffffff810b6452>] lock_acquire+0x92/0x120
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150586]        [<ffffffff81482b76>] _raw_spin_lock_bh+0x36/0x50
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150592]        [<ffffffffa06775ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150601]        [<ffffffffa0674b4d>] nr_device_event+0x7d/0xa0 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150608]        [<ffffffff81487388>] notifier_call_chain+0x58/0xb0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150617]        [<ffffffff810810c6>] raw_notifier_call_chain+0x16/0x20
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150625]        [<ffffffff813ae526>] call_netdevice_notifiers+0x36/0x60
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150633]        [<ffffffff813ae71f>] dev_close_many+0xbf/0x100
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150639]        [<ffffffff813ae838>] rollback_registered_many+0xd8/0x250
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150645]        [<ffffffff813aea4d>] rollback_registered+0x2d/0x40
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150653]        [<ffffffff813b17a8>] unregister_netdevice_queue+0x68/0xc0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150659]        [<ffffffff813b1820>] unregister_netdev+0x20/0x30
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150666]        [<ffffffffa05df4e7>] mkiss_close+0x57/0x90 [mkiss]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150674]        [<ffffffff81309ed1>] tty_ldisc_close.isra.2+0x41/0x60
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150683]        [<ffffffff8130a0d0>] tty_ldisc_reinit+0x40/0x80
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150689]        [<ffffffff8130a850>] tty_ldisc_hangup+0x190/0x340
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150695]        [<ffffffff81301f8a>] __tty_hangup+0x10a/0x3c0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150703]        [<ffffffff8130226e>] tty_vhangup+0xe/0x10
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150709]        [<ffffffff8130c66e>] pty_close+0x10e/0x180
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150716]        [<ffffffff81303212>] tty_release+0x182/0x5c0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150724]        [<ffffffff8117bf9e>] __fput+0xae/0x230
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150734]        [<ffffffff8117c12e>] ____fput+0xe/0x10
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150740]        [<ffffffff81076fb9>] task_work_run+0x69/0x90
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150748]        [<ffffffff8105abef>] do_exit+0x87f/0x900
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150756]        [<ffffffff8105afce>] do_group_exit+0x4e/0xc0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150763]        [<ffffffff8105b057>] sys_exit_group+0x17/0x20
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150770]        [<ffffffff8148b6b9>] system_call_fastpath+0x16/0x1b
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150778] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150778] other info that might help us debug this:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150778] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150782] Chain exists of:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150782]   nr_node_list_lock --> &(&nr_node->node_lock)->rlock --> nr_neigh_list_lock
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150782] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150799]  Possible unsafe locking scenario:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150799] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150803]        CPU0                    CPU1
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150806]        ----                    ----
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150809]   lock(nr_neigh_list_lock);
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150819]                                lock(&(&nr_node->node_lock)->rlock);
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150826]                                lock(nr_neigh_list_lock);
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150834]   lock(nr_node_list_lock);
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150842] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150842]  *** DEADLOCK ***
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150842] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150847] 4 locks held by ax25ipd/1580:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150851]  #0:  (big_tty_mutex){+.+.+.}, at: [<ffffffff814832d7>] tty_lock+0x17/0x19
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150867]  #1:  (&tty->ldisc_mutex){+.+.+.}, at: [<ffffffff8130a7d7>] tty_ldisc_hangup+0x117/0x340
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150885]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff813c11c7>] rtnl_lock+0x17/0x20
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150901]  #3:  (nr_neigh_list_lock){+.-.-.}, at: [<ffffffffa0677596>] nr_rt_device_down+0x26/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150921] 
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150921] stack backtrace:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150927] Pid: 1580, comm: ax25ipd Not tainted 3.6.1 #1
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150930] Call Trace:
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150938]  [<ffffffff81479b5a>] print_circular_bug+0x289/0x29a
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150945]  [<ffffffff810b5c41>] __lock_acquire+0x1a91/0x1ce0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150954]  [<ffffffffa06775ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150960]  [<ffffffff810b6452>] lock_acquire+0x92/0x120
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150969]  [<ffffffffa06775ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150976]  [<ffffffff81482b76>] _raw_spin_lock_bh+0x36/0x50
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150984]  [<ffffffffa06775ec>] ? nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150990]  [<ffffffff810b6ec5>] ? trace_hardirqs_on_caller+0x105/0x190
Oct 21 12:10:36 f6bvp-8 kernel: [522519.150997]  [<ffffffffa0674b41>] ? nr_device_event+0x71/0xa0 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151005]  [<ffffffffa06775ec>] nr_rt_device_down+0x7c/0x240 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151011]  [<ffffffff8105d1a7>] ? local_bh_enable_ip+0x97/0x100
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151019]  [<ffffffffa0674b4d>] nr_device_event+0x7d/0xa0 [netrom]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151026]  [<ffffffff81487388>] notifier_call_chain+0x58/0xb0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151033]  [<ffffffff810810c6>] raw_notifier_call_chain+0x16/0x20
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151038]  [<ffffffff813ae526>] call_netdevice_notifiers+0x36/0x60
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151044]  [<ffffffff813ae71f>] dev_close_many+0xbf/0x100
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151050]  [<ffffffff813ae838>] rollback_registered_many+0xd8/0x250
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151055]  [<ffffffff813aea4d>] rollback_registered+0x2d/0x40
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151061]  [<ffffffff813b17a8>] unregister_netdevice_queue+0x68/0xc0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151068]  [<ffffffff813b1820>] unregister_netdev+0x20/0x30
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151077]  [<ffffffffa05df4e7>] mkiss_close+0x57/0x90 [mkiss]
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151083]  [<ffffffff81309ed1>] tty_ldisc_close.isra.2+0x41/0x60
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151089]  [<ffffffff8130a0d0>] tty_ldisc_reinit+0x40/0x80
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151094]  [<ffffffff8130a850>] tty_ldisc_hangup+0x190/0x340
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151101]  [<ffffffff81301f8a>] __tty_hangup+0x10a/0x3c0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151107]  [<ffffffff810b6f5d>] ? trace_hardirqs_on+0xd/0x10
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151114]  [<ffffffff8130226e>] tty_vhangup+0xe/0x10
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151120]  [<ffffffff8130c66e>] pty_close+0x10e/0x180
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151126]  [<ffffffff81303212>] tty_release+0x182/0x5c0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151132]  [<ffffffff81192d92>] ? dput+0x62/0x1b0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151138]  [<ffffffff8117bf9e>] __fput+0xae/0x230
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151144]  [<ffffffff8117c12e>] ____fput+0xe/0x10
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff81076fb9>] task_work_run+0x69/0x90
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff8105abef>] do_exit+0x87f/0x900
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff81483495>] ? retint_swapgs+0x13/0x1b
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff8105afce>] do_group_exit+0x4e/0xc0
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff8105b057>] sys_exit_group+0x17/0x20
Oct 21 12:10:36 f6bvp-8 kernel: [522519.151148]  [<ffffffff8148b6b9>] system_call_fastpath+0x16/0x1b


--------------020702000803080705030904--
