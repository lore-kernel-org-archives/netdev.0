From: Peter Neal <doabackflip@gmail.com>
Subject: Re: igb transmit queue timed out, rcu_sched_state detected stall
Date: Mon, 15 Aug 2011 15:33:07 +0100
Message-ID: <CALJvf+qGt=GkD2oV8GEz7DWLzpCZGaAE5Gpse8HvPjgpT2Wmxw@mail.gmail.com>
References: <CALJvf+qLZyXpxfDR-3aJVn2Qf558SKPc85NpQOosafqxCUC46w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f170.google.com ([209.85.210.170]:52328 "EHLO
	mail-iy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab1HOOdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 10:33:08 -0400
Received: by iye16 with SMTP id 16so7592944iye.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 07:33:07 -0700 (PDT)
In-Reply-To: <CALJvf+qLZyXpxfDR-3aJVn2Qf558SKPc85NpQOosafqxCUC46w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have updated the BIOS, iproute2, e1000e and igb drivers, but am
still seeing issues, any thoughts?

Thanks,


Pete

[ 7765.881893] bnx2 0000:0b:00.0: eth25: NIC Copper Link is Up, 1000
Mbps full duplex, receive & transmit flow control ON
[ 7767.395912] bnx2 0000:0b:00.0: eth25: NIC Copper Link is Down
[ 7769.832448] bnx2 0000:0b:00.0: eth25: NIC Copper Link is Up, 1000
Mbps full duplex, receive & transmit flow control ON
[ 7778.124580] igb: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7783.001120] igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7783.900216] igb: eth4 NIC Link is Down
[ 7786.204560] igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7788.168523] igb: eth18 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7789.414458] igb: eth18 NIC Link is Down
[ 7791.702958] igb: eth18 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7794.188210] igb: eth12 NIC Link is Down
[ 7796.432599] igb: eth12 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7826.864941] e1000e: eth21 NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: Rx/Tx
[ 7836.544159] igb: eth17 NIC Link is Down
[ 7864.112307] igb: eth6 NIC Link is Down
[ 7917.072196] igb: eth16 NIC Link is Down
[ 7919.356618] igb: eth16 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7920.848574] igb: eth10 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7926.272173] igb: eth4 NIC Link is Down
[ 7965.212587] igb: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7966.200164] igb: eth6 NIC Link is Down
[ 7968.742002] igb: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7971.112151] e1000e: eth20 NIC Link is Down
[ 7973.084709] igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 7973.452998] e1000e: eth20 NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: Rx/Tx
[ 7974.300193] igb: eth4 NIC Link is Down
[ 7976.616567] igb: eth4 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 8041.200005] INFO: rcu_sched_state detected stall on CPU 2 (t=15000 jiffies)
[ 8041.835999] INFO: rcu_bh_state detected stall on CPU 2 (t=15000 jiffies)
[ 8060.251724] bnx2 0000:0b:00.0: eth25: NIC Copper Link is Down
[ 8096.268889] bnx2 0000:0b:00.0: eth25: NIC Copper Link is Up, 1000
Mbps full duplex, receive & transmit flow control ON
[ 8161.920070] INFO: task irqbalance:1777 blocked for more than 120 seconds.
[ 8162.001213] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8162.094833] irqbalance      D ffff88042e9abd50     0  1777      1 0x00000000
[ 8162.179119]  ffff88042e9abd50 0000000000000086 ffff88042e9abd50
ffff88042ec6a8e0
[ 8162.267569]  0000000000012680 ffff88042b5fdfd8 ffff88042b5fdfd8
0000000000012680
[ 8162.356047]  ffff88042e9abd50 ffff88042b5fc010 0000000100000000
ffff88042b995f60
[ 8162.444498] Call Trace:
[ 8162.473641]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8162.548540]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8162.611996]  [<ffffffff81269ca6>] ? dev_load+0x9/0x70
[ 8162.672333]  [<ffffffff8126b017>] ? dev_ioctl+0x4ad/0x62e
[ 8162.736839]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[ 8162.803415]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[ 8162.868959]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[ 8162.937616]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[ 8163.005235]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[ 8163.074938]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8163.138393]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[ 8163.200810]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8163.274672] INFO: task snmpd:1797 blocked for more than 120 seconds.
[ 8163.350609] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8163.444228] snmpd           D ffff88042aa4d890     0  1797      1 0x00000000
[ 8163.528516]  ffff88042aa4d890 0000000000000086 ffff88042aa4d890
ffff88042ec6a8e0
[ 8163.616962]  0000000000012680 ffff88042d7b7fd8 ffff88042d7b7fd8
0000000000012680
[ 8163.705415]  ffff88042aa4d890 ffff88042d7b6010 0000000100000000
ffff88042b995f60
[ 8163.793870] Call Trace:
[ 8163.823001]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8163.897900]  [<ffffffff810fa4b3>] ? dget+0x12/0x1e
[ 8163.955115]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8164.018572]  [<ffffffff8126aba4>] ? dev_ioctl+0x3a/0x62e
[ 8164.082034]  [<ffffffff81103734>] ? dput+0x29/0xe9
[ 8164.139253]  [<ffffffff810eb735>] ? get_partial_node+0x15/0x7b
[ 8164.208949]  [<ffffffff810f3cfa>] ? get_empty_filp+0x69/0x12b
[ 8164.277606]  [<ffffffff8125844c>] ? sock_do_ioctl+0x2f/0x36
[ 8164.344186]  [<ffffffff81258853>] ? sock_ioctl+0x205/0x212
[ 8164.409721]  [<ffffffff810f3d2d>] ? get_empty_filp+0x9c/0x12b
[ 8164.478377]  [<ffffffff810ff9bb>] ? do_vfs_ioctl+0x467/0x4b4
[ 8164.545996]  [<ffffffff81259ed4>] ? sock_alloc_file+0xae/0x10c
[ 8164.615696]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8164.679156]  [<ffffffff810ffa53>] ? sys_ioctl+0x4b/0x70
[ 8164.741574]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8164.815438] INFO: task sshd:806 blocked for more than 120 seconds.
[ 8164.889300] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8164.982918] sshd            D ffff88042d62e630     0   806   1814 0x00000000
[ 8165.067195]  ffff88042d62e630 0000000000000086 ffff88042d62e630
ffff88042edb5890
[ 8165.155645]  0000000000012680 ffff8803fa8fffd8 ffff8803fa8fffd8
0000000000012680
[ 8165.244109]  ffff88042d62e630 ffff8803fa8fe010 0000000100000000
ffff88042b995f60
[ 8165.332561] Call Trace:
[ 8165.361699]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8165.436600]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8165.500064]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8165.565602]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8165.635298]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8165.706044]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8165.779901]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8165.845439]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8165.907854]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8165.975475]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8166.048289]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8166.112785]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8166.176242]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8166.250105] INFO: task sshd:807 blocked for more than 120 seconds.
[ 8166.323964] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8166.417581] sshd            D ffff88042a491470     0   807   1814 0x00000000
[ 8166.501865]  ffff88042a491470 0000000000000086 ffff88042a491470
ffff88042edb73d0
[ 8166.590321]  0000000000012680 ffff8803e7e37fd8 ffff8803e7e37fd8
0000000000012680
[ 8166.678785]  ffff88042a491470 ffff8803e7e36010 0000000100000000
ffff88042b995f60
[ 8166.767243] Call Trace:
[ 8166.796385]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8166.871289]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8166.934748]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8167.000284]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8167.069987]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8167.140727]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8167.214584]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8167.280121]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8167.342543]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8167.410162]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8167.482978]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8167.547477]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8167.610937]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8167.684797] INFO: task sshd:808 blocked for more than 120 seconds.
[ 8167.758654] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8167.852272] sshd            D ffff88042a494420     0   808   1814 0x00000000
[ 8167.936556]  ffff88042a494420 0000000000000082 ffff88042a494420
ffff88042e9a8000
[ 8168.025020]  0000000000012680 ffff88042daa9fd8 ffff88042daa9fd8
0000000000012680
[ 8168.113482]  ffff88042a494420 ffff88042daa8010 0000000100000000
ffff88042b995f60
[ 8168.201947] Call Trace:
[ 8168.231085]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8168.305981]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8168.369438]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8168.434979]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8168.504672]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8168.575409]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8168.649267]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8168.714811]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8168.777228]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8168.844848]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8168.917663]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8168.982164]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8169.045621]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8169.119480] INFO: task sshd:809 blocked for more than 120 seconds.
[ 8169.193337] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8169.286959] sshd            D ffff88042b8186d0     0   809   1814 0x00000000
[ 8169.371232]  ffff88042b8186d0 0000000000000086 ffff88042b8186d0
ffff88042e9a8da0
[ 8169.459683]  0000000000012680 ffff8803ef68bfd8 ffff8803ef68bfd8
0000000000012680
[ 8169.548141]  ffff88042b8186d0 ffff8803ef68a010 0000000100000000
ffff88042b995f60
[ 8169.636603] Call Trace:
[ 8169.665736]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8169.740634]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8169.804095]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8169.869632]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8169.939330]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8170.010066]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8170.083929]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8170.149469]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8170.211886]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8170.279502]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8170.352323]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8170.416818]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8170.480274]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8170.554131] INFO: task smtpserver.pl:815 blocked for more than 120 seconds.
[ 8170.637354] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8170.730974] smtpserver.pl   D ffff88042b81caf0     0   815  31144 0x00000004
[ 8170.815252]  ffff88042b81caf0 0000000000000082 ffff88042b81caf0
ffff88042ee03d50
[ 8170.903706]  0000000000012680 ffff88042e929fd8 ffff88042e929fd8
0000000000012680
[ 8170.992174]  ffff88042b81caf0 ffff88042e928010 0000000100000000
ffff88042b995f60
[ 8171.080630] Call Trace:
[ 8171.109767]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8171.184668]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8171.248126]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8171.313665]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8171.383361]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8171.454104]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8171.527962]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8171.593500]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8171.655915]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8171.723538]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8171.796356]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8171.860854]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8171.924311]  [<ffffffff81259f56>] ? sock_map_fd+0x24/0x2d
[ 8171.988812]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8172.062672] INFO: task sshd:823 blocked for more than 120 seconds.
[ 8172.136527] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8172.230147] sshd            D ffff88042a496d00     0   823   1814 0x00000000
[ 8172.314431]  ffff88042a496d00 0000000000000082 ffff88042a496d00
ffff88042edb73d0
[ 8172.402881]  0000000000012680 ffff88042a9cdfd8 ffff88042a9cdfd8
0000000000012680
[ 8172.491319]  ffff88042a496d00 ffff88042a9cc010 0000000100000000
ffff88042b995f60
[ 8172.579783] Call Trace:
[ 8172.608922]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8172.683819]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8172.747277]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8172.812815]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8172.882512]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8172.953247]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8173.027105]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8173.092645]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8173.155065]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8173.222680]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8173.295499]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8173.360015]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8173.423471]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8173.497329] INFO: task sshd:872 blocked for more than 120 seconds.
[ 8173.571185] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8173.664810] sshd            D ffff88042d6286d0     0   872   1814 0x00000000
[ 8173.749088]  ffff88042d6286d0 0000000000000082 ffff88042d6286d0
ffff88042edb5890
[ 8173.837545]  0000000000012680 ffff8803eabf3fd8 ffff8803eabf3fd8
0000000000012680
[ 8173.926005]  ffff88042d6286d0 ffff8803eabf2010 0000000100000000
ffff88042b995f60
[ 8174.014447] Call Trace:
[ 8174.043585]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8174.118483]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8174.181943]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8174.247482]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8174.317178]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8174.387918]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8174.461779]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8174.527317]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8174.589734]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8174.657352]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8174.730176]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8174.794674]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8174.858132]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8174.931986] INFO: task sshd:873 blocked for more than 120 seconds.
[ 8175.005847] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 8175.099461] sshd            D ffff88042a494af0     0   873   1814 0x00000000
[ 8175.183739]  ffff88042a494af0 0000000000000082 ffff88042a494af0
ffff88042edb73d0
[ 8175.272197]  0000000000012680 ffff8804084f7fd8 ffff8804084f7fd8
0000000000012680
[ 8175.360649]  ffff88042a494af0 ffff8804084f6010 0000000100000000
ffff88042b995f60
[ 8175.449106] Call Trace:
[ 8175.478243]  [<ffffffff81322df5>] ? __mutex_lock_common+0x10c/0x172
[ 8175.553145]  [<ffffffff81322f21>] ? mutex_lock+0x1a/0x2c
[ 8175.616602]  [<ffffffff81275f2e>] ? rtnetlink_rcv+0xe/0x28
[ 8175.682139]  [<ffffffff8128951f>] ? netlink_unicast+0xea/0x152
[ 8175.751838]  [<ffffffff81289c74>] ? netlink_sendmsg+0x246/0x266
[ 8175.822579]  [<ffffffff8125809a>] ? __sock_sendmsg_nosec+0x25/0x5d
[ 8175.896438]  [<ffffffff812590dc>] ? sock_sendmsg+0x83/0x9b
[ 8175.961976]  [<ffffffff810378ce>] ? __wake_up+0x35/0x46
[ 8176.024393]  [<ffffffff8125838d>] ? copy_from_user+0x18/0x30
[ 8176.092023]  [<ffffffff81258e23>] ? move_addr_to_kernel+0x2c/0x4c
[ 8176.164846]  [<ffffffff812595fc>] ? sys_sendto+0xf7/0x137
[ 8176.229343]  [<ffffffff810f0dc5>] ? fd_install+0x27/0x4e
[ 8176.292800]  [<ffffffff81329d52>] ? system_call_fastpath+0x16/0x1b
[ 8221.320008] INFO: rcu_sched_state detected stall on CPU 2 (t=60030 jiffies)
[ 8221.955999] INFO: rcu_bh_state detected stall on CPU 2 (t=60030 jiffies)
[ 8401.440001] INFO: rcu_sched_state detected stall on CPU 2 (t=105060 jiffies)
[ 8402.076002] INFO: rcu_bh_state detected stall on CPU 2 (t=105060 jiffies)
