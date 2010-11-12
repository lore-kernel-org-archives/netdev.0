From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Fwd: WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
  2.6.35.7
Date: Fri, 12 Nov 2010 22:21:52 +0200
Message-ID: <20101112202151.GB5625@core2.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: udovdh@xs4all.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44992 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541Ab0KLUV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:21:58 -0500
Received: by eye27 with SMTP id 27so2172113eye.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 12:21:56 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Forwarded message from Udo van den Heuvel <udovdh@xs4all.nl> -----

From: Udo van den Heuvel <udovdh@xs4all.nl>
To: linux-kernel@vger.kernel.org
Subject: WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()  2.6.35.7
Date: Thu, 11 Nov 2010 17:56:50 +0100

Hello,

Should apps like NetworkManager cause stuff like in the logs added below?
What happened?
How to fix?

Kind regards,
Udo

------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19225, comm: NetworkManager Not tainted 2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff8137a9c0>] ? fib6_prune_clone+0x0/0x20
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff81043cdd>] ? local_bh_enable_ip+0x4d/0xb0
 [<ffffffff81374405>] ? addrconf_notify+0xe5/0x910
 [<ffffffff8104a013>] ? lock_timer_base+0x33/0x70
 [<ffffffff813a84b2>] ? _raw_spin_unlock_irqrestore+0x12/0x40
 [<ffffffff8104a8bd>] ? mod_timer+0x14d/0x250
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff8105acf6>] ? notifier_call_chain+0x46/0x70
 [<ffffffff812f91d5>] ? __dev_notify_flags+0x65/0x90
 [<ffffffff812f923b>] ? dev_change_flags+0x3b/0x70
 [<ffffffff81304f09>] ? do_setlink+0x189/0x740
 [<ffffffff811c1da0>] ? nla_parse+0x30/0x100
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff81305597>] ? rtnl_setlink+0xd7/0x120
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff8110e3a9>] ? dquot_file_open+0x19/0x60
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff8108d709>] ? file_read_actor+0x179/0x1b0
 [<ffffffff811ae452>] ? cpumask_any_but+0x22/0x40
 [<ffffffff8102b27c>] ? flush_tlb_page+0x5c/0xe0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff810c0972>] ? fget_light+0xb2/0xf0
 [<ffffffff812e7946>] ? move_addr_to_kernel+0x46/0x70
 [<ffffffff812f185a>] ? verify_iovec+0x6a/0xc0
 [<ffffffff812e58bb>] ? sys_sendmsg+0x23b/0x380
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81026829>] ? do_page_fault+0x199/0x3b0
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff810c0972>] ? fget_light+0xb2/0xf0
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc82 ]---
fib6_clean_node: del failed: rt=ffff880037a84200@98c20d5400000000 err=-2
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19225, comm: NetworkManager Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff813a5a16>] ? printk+0x40/0x4a
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff81043cdd>] ? local_bh_enable_ip+0x4d/0xb0
 [<ffffffff81374405>] ? addrconf_notify+0xe5/0x910
 [<ffffffff8104a013>] ? lock_timer_base+0x33/0x70
 [<ffffffff813a84b2>] ? _raw_spin_unlock_irqrestore+0x12/0x40
 [<ffffffff8104a8bd>] ? mod_timer+0x14d/0x250
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff8105acf6>] ? notifier_call_chain+0x46/0x70
 [<ffffffff812f91d5>] ? __dev_notify_flags+0x65/0x90
 [<ffffffff812f923b>] ? dev_change_flags+0x3b/0x70
 [<ffffffff81304f09>] ? do_setlink+0x189/0x740
 [<ffffffff811c1da0>] ? nla_parse+0x30/0x100
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff81305597>] ? rtnl_setlink+0xd7/0x120
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff8110e3a9>] ? dquot_file_open+0x19/0x60
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff8108d709>] ? file_read_actor+0x179/0x1b0
 [<ffffffff811ae452>] ? cpumask_any_but+0x22/0x40
 [<ffffffff8102b27c>] ? flush_tlb_page+0x5c/0xe0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff810c0972>] ? fget_light+0xb2/0xf0
 [<ffffffff812e7946>] ? move_addr_to_kernel+0x46/0x70
 [<ffffffff812f185a>] ? verify_iovec+0x6a/0xc0
 [<ffffffff812e58bb>] ? sys_sendmsg+0x23b/0x380
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81026829>] ? do_page_fault+0x199/0x3b0
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff810c0972>] ? fget_light+0xb2/0xf0
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc83 ]---
fib6_clean_node: del failed: rt=ffff88012ae4b200@620aa8c000000000 err=-2
r8169 0000:03:00.0: eth0: link up
eth0: no IPv6 routers present
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19514, comm: NetworkManager Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff810386af>] ? load_balance+0xbf/0x6b0
 [<ffffffff8103201f>] ? dequeue_task_fair+0x4f/0x1c0
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff81043cdd>] ? local_bh_enable_ip+0x4d/0xb0
 [<ffffffff81374405>] ? addrconf_notify+0xe5/0x910
 [<ffffffff8104a013>] ? lock_timer_base+0x33/0x70
 [<ffffffff813a84b2>] ? _raw_spin_unlock_irqrestore+0x12/0x40
 [<ffffffff8104a8bd>] ? mod_timer+0x14d/0x250
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff8105acf6>] ? notifier_call_chain+0x46/0x70
 [<ffffffff812f91d5>] ? __dev_notify_flags+0x65/0x90
 [<ffffffff812f923b>] ? dev_change_flags+0x3b/0x70
 [<ffffffff81304f09>] ? do_setlink+0x189/0x740
 [<ffffffff811c1da0>] ? nla_parse+0x30/0x100
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff81305597>] ? rtnl_setlink+0xd7/0x120
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff8110e3a9>] ? dquot_file_open+0x19/0x60
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff8108d709>] ? file_read_actor+0x179/0x1b0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff812e7946>] ? move_addr_to_kernel+0x46/0x70
 [<ffffffff812f185a>] ? verify_iovec+0x6a/0xc0
 [<ffffffff812e58bb>] ? sys_sendmsg+0x23b/0x380
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035c8f>] ? add_preempt_count+0x5f/0xb0
 [<ffffffff81043c7e>] ? local_bh_disable+0xe/0x20
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff810d1d2f>] ? d_kill+0x5f/0x80
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc84 ]---
fib6_clean_node: del failed: rt=ffff88012ae4b200@620aa8c000000000 err=-2
fib6_clean_node: del failed: rt=ffff8800250edd00@(null) err=-2
fib6_clean_node: del failed: rt=ffff88012d877840@(null) err=-2
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19678, comm: ip Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff8137a9c0>] ? fib6_prune_clone+0x0/0x20
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff813741f6>] ? inet6_addr_del+0x106/0x130
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff81374285>] ? inet6_rtm_deladdr+0x65/0x70
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff810a3f2a>] ? __do_fault+0x40a/0x520
 [<ffffffff812e6cc8>] ? move_addr_to_user+0x88/0xa0
 [<ffffffff812e6e2d>] ? __sys_recvmsg+0x14d/0x290
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff812e5622>] ? sockfd_lookup_light+0x22/0x80
 [<ffffffff812e7a8d>] ? sys_sendto+0x11d/0x180
 [<ffffffff810ab0ca>] ? vma_link+0xaa/0x110
 [<ffffffff810ac5bd>] ? do_brk+0x2fd/0x330
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc85 ]---
fib6_clean_node: del failed: rt=ffff880028faa340@ffff8800250a6e40 err=-2
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19678, comm: ip Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff813a5a16>] ? printk+0x40/0x4a
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff813741f6>] ? inet6_addr_del+0x106/0x130
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff81374285>] ? inet6_rtm_deladdr+0x65/0x70
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff810a3f2a>] ? __do_fault+0x40a/0x520
 [<ffffffff812e6cc8>] ? move_addr_to_user+0x88/0xa0
 [<ffffffff812e6e2d>] ? __sys_recvmsg+0x14d/0x290
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff812e5622>] ? sockfd_lookup_light+0x22/0x80
 [<ffffffff812e7a8d>] ? sys_sendto+0x11d/0x180
 [<ffffffff810ab0ca>] ? vma_link+0xaa/0x110
 [<ffffffff810ac5bd>] ? do_brk+0x2fd/0x330
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc86 ]---
fib6_clean_node: del failed: rt=ffff8800ce662cc0@0100007f00000000 err=-2
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19679, comm: ip Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff810386af>] ? load_balance+0xbf/0x6b0
 [<ffffffff8103201f>] ? dequeue_task_fair+0x4f/0x1c0
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff81043cdd>] ? local_bh_enable_ip+0x4d/0xb0
 [<ffffffff81374405>] ? addrconf_notify+0xe5/0x910
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff8137a9e0>] ? fib6_age+0x0/0x80
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff8105acf6>] ? notifier_call_chain+0x46/0x70
 [<ffffffff812f91d5>] ? __dev_notify_flags+0x65/0x90
 [<ffffffff812f923b>] ? dev_change_flags+0x3b/0x70
 [<ffffffff81304f09>] ? do_setlink+0x189/0x740
 [<ffffffff811c1da0>] ? nla_parse+0x30/0x100
 [<ffffffff813061e9>] ? rtnl_newlink+0x3e9/0x4f0
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff813a84b2>] ? _raw_spin_unlock_irqrestore+0x12/0x40
 [<ffffffff812f28ba>] ? __skb_recv_datagram+0xca/0x280
 [<ffffffff81305c15>] ? rtnetlink_rcv_msg+0x85/0x270
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff8108e18d>] ? find_get_page+0x6d/0xd0
 [<ffffffff8108eb19>] ? filemap_fault+0x99/0x400
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff810a3f2a>] ? __do_fault+0x40a/0x520
 [<ffffffff812e7946>] ? move_addr_to_kernel+0x46/0x70
 [<ffffffff812f185a>] ? verify_iovec+0x6a/0xc0
 [<ffffffff812e58bb>] ? sys_sendmsg+0x23b/0x380
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81026829>] ? do_page_fault+0x199/0x3b0
 [<ffffffff810ab0ca>] ? vma_link+0xaa/0x110
 [<ffffffff810ac5bd>] ? do_brk+0x2fd/0x330
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc87 ]---
fib6_clean_node: del failed: rt=ffff880028faa340@ffff8800250a6e40 err=-2
------------[ cut here ]------------
WARNING: at net/ipv6/ip6_fib.c:1172 fib6_del+0x4f6/0x5a0()
Hardware name:
Modules linked in: sit tunnel4 nls_utf8 isofs vfat fat usb_storage
vboxnetadp vboxnetflt vboxdrv radeon ttm drm_kms_helper drm fb fbdev
i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect rfcomm sco bridge stp llc
bnep l2cap nfsd nfs_acl auth_rpcgss exportfs eeprom it87 hwmon_vid lockd
sunrpc powernow_k8 mperf ipt_REJECT iptable_filter ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables
nf_conntrack_netbios_ns ip6t_REJECT xt_tcpudp nf_conntrack_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables x_tables binfmt_misc dm_mirror
dm_region_hash dm_log ppdev snd_hda_codec_atihdmi snd_hda_codec_realtek
pwc snd_seq snd_seq_device videodev parport_pc snd_hda_intel
snd_hda_codec k10temp snd_pcm ohci1394 snd_timer btusb ieee1394 snd
v4l1_compat v4l2_compat_ioctl32 i2c_piix4 usblp evdev sg parport
bluetooth button snd_page_alloc sr_mod cdrom ide_pci_generic atiixp
pata_atiixp ehci_hcd ohci_hcd sata_sil24 floppy [last unloaded:
scsi_wait_scan]
Pid: 19679, comm: ip Tainted: G        W   2.6.35.7 #10
Call Trace:
 [<ffffffff8103e02b>] ? warn_slowpath_common+0x7b/0xc0
 [<ffffffff8137b7b6>] ? fib6_del+0x4f6/0x5a0
 [<ffffffff810386af>] ? load_balance+0xbf/0x6b0
 [<ffffffff813a5a16>] ? printk+0x40/0x4a
 [<ffffffff8137b8bc>] ? fib6_clean_node+0x5c/0xc0
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137acd6>] ? fib6_walk_continue+0x156/0x170
 [<ffffffff8137ad41>] ? fib6_walk+0x51/0xb0
 [<ffffffff813a8533>] ? _raw_write_lock_bh+0x13/0x30
 [<ffffffff8137b177>] ? fib6_clean_all+0x97/0xe0
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff81377130>] ? fib6_ifdown+0x0/0x30
 [<ffffffff8137a8e6>] ? rt6_ifdown+0x26/0xc0
 [<ffffffff81373b88>] ? addrconf_ifdown+0x48/0x4e0
 [<ffffffff81043cdd>] ? local_bh_enable_ip+0x4d/0xb0
 [<ffffffff81374405>] ? addrconf_notify+0xe5/0x910
 [<ffffffff8137b860>] ? fib6_clean_node+0x0/0xc0
 [<ffffffff8137a9e0>] ? fib6_age+0x0/0x80
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff8105acf6>] ? notifier_call_chain+0x46/0x70
 [<ffffffff812f91d5>] ? __dev_notify_flags+0x65/0x90
 [<ffffffff812f923b>] ? dev_change_flags+0x3b/0x70
 [<ffffffff81304f09>] ? do_setlink+0x189/0x740
 [<ffffffff811c1da0>] ? nla_parse+0x30/0x100
 [<ffffffff813061e9>] ? rtnl_newlink+0x3e9/0x4f0
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff813a84b2>] ? _raw_spin_unlock_irqrestore+0x12/0x40
 [<ffffffff812f28ba>] ? __skb_recv_datagram+0xca/0x280
 [<ffffffff81305c15>] ? rtnetlink_rcv_msg+0x85/0x270
 [<ffffffff81305b90>] ? rtnetlink_rcv_msg+0x0/0x270
 [<ffffffff813153e9>] ? netlink_rcv_skb+0x89/0xb0
 [<ffffffff81305b7f>] ? rtnetlink_rcv+0x1f/0x30
 [<ffffffff81314fe5>] ? netlink_unicast+0x2a5/0x2f0
 [<ffffffff8131592c>] ? netlink_sendmsg+0x1fc/0x300
 [<ffffffff812e559e>] ? sock_sendmsg+0xfe/0x110
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff8108e18d>] ? find_get_page+0x6d/0xd0
 [<ffffffff8108eb19>] ? filemap_fault+0x99/0x400
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff810a3f2a>] ? __do_fault+0x40a/0x520
 [<ffffffff812e7946>] ? move_addr_to_kernel+0x46/0x70
 [<ffffffff812f185a>] ? verify_iovec+0x6a/0xc0
 [<ffffffff812e58bb>] ? sys_sendmsg+0x23b/0x380
 [<ffffffff81034349>] ? get_parent_ip+0x9/0x20
 [<ffffffff81035bff>] ? sub_preempt_count+0x7f/0xb0
 [<ffffffff81026829>] ? do_page_fault+0x199/0x3b0
 [<ffffffff810ab0ca>] ? vma_link+0xaa/0x110
 [<ffffffff810ac5bd>] ? do_brk+0x2fd/0x330
 [<ffffffff8107a9d8>] ? audit_syscall_entry+0x1b8/0x1e0
 [<ffffffff810023eb>] ? system_call_fastpath+0x16/0x1b
---[ end trace 286af05228c1bc88 ]---
fib6_clean_node: del failed: rt=ffff8800ce662cc0@0100007f00000000 err=-2
fib6_clean_node: del failed: rt=ffff880028faad40@(null) err=-2
lo: Disabled Privacy Extensions
r8169 0000:03:00.0: eth0: link up
usb0: no IPv6 routers present
fib6_clean_node: del failed: rt=ffff880028faa5c0@(null) err=-2
fib6_clean_node: del failed: rt=ffff880028faa5c0@(null) err=-2
fib6_clean_node: del failed: rt=ffff880028faa5c0@(null) err=-2
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----
