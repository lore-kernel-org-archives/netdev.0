From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54601] New: PPP regression on 3.2.39 stop work need
 restart server ont version 3.2.21 not found this problem.
Date: Fri, 1 Mar 2013 08:47:05 -0800
Message-ID: <20130301084705.4169c429@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:39149 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3CAQrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 11:47:08 -0500
Received: by mail-da0-f49.google.com with SMTP id t11so1480189daj.36
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 08:47:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 1 Mar 2013 01:24:14 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54601] New: PPP regression on 3.2.39 stop work need restart server ont version 3.2.21 not found this problem.


https://bugzilla.kernel.org/show_bug.cgi?id=54601

           Summary: PPP regression on 3.2.39 stop work need restart server
                    ont version 3.2.21 not found this problem.
           Product: Networking
           Version: 2.5
    Kernel Version: 3.2.39
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: micron10@gmail.com
        Regression: Yes


Hi
watch a problem with PPP after upgrade to version 3.2.39 ppp service stop work
2 hours after start with this crash :

[79619.180026] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 562
[79629.320074] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 529
[79639.460103] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 506
[79649.600071] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 486
[79659.740092] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 465
[79669.880014] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 444
[79680.020065] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 422
[79690.160111] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 402
[79700.300077] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 379
[79710.440018] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 355
[79720.580031] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 334
[79730.720082] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 313
[79740.860050] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 291
[79751.000030] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 268
[79761.140024] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 247
[79771.280201] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 223
[79781.420028] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 202
[79791.560098] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 180
[79801.700042] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 159
[79804.410096] INFO: task pppd:31852 blocked for more than 120 seconds.
[79804.410098] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410101] pppd            D ffff88015fd0cd00     0 31852  31800 0x00000004
[79804.410111]  ffff88010b69d600 0000000000000086 ffff88010b69d600
ffffffff8166e800
[79804.410114]  ffff880159120ac0 0000000000004000 ffff88010ba75fd8
ffff88010ba75fd8
[79804.410117]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410119] Call Trace:
[79804.410128]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410150]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410155]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410167]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410170]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410172]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410176]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410178]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410181]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410190]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410193]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410195]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410198] INFO: task pppd:31869 blocked for more than 120 seconds.
[79804.410199] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410201] pppd            D ffff88015fc0cd00     0 31869  31800 0x00000004
[79804.410203]  ffff88014b1deb80 0000000000000082 ffff88014b1deb80
ffffffff8166e800
[79804.410206]  ffff8801591250a0 0000000000004000 ffff88015829ffd8
ffff88015829ffd8
[79804.410209]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410212] Call Trace:
[79804.410214]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410216]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410218]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410221]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410223]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410226]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410228]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410249]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410251]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410253]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410256]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410258]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410260] INFO: task pppd:31889 blocked for more than 120 seconds.
[79804.410261] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410262] pppd            D ffff88015fc0cd00     0 31889  31800 0x00000000
[79804.410275]  ffff880159868ac0 0000000000000086 ffff880159868ac0
ffffffff8166e800
[79804.410277]  ffff8801599ab060 0000000000004000 ffff88014ba51fd8
ffff88014ba51fd8
[79804.410280]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410290] Call Trace:
[79804.410292]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410295]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410297]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410300]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410302]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410305]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410318]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410321]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410322]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410325]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410327]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410330]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410334] INFO: task pppd:31890 blocked for more than 120 seconds.
[79804.410335] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410337] pppd            D ffff88015fd0cd00     0 31890  31800 0x00000000
[79804.410339]  ffff88015986cb40 0000000000000082 ffff88015986cb40
ffffffff8166e800
[79804.410342]  ffff8801599adb60 0000000000004000 ffff8801079d7fd8
ffff8801079d7fd8
[79804.410345]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410347] Call Trace:
[79804.410349]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410352]  [<ffffffff810b94a7>] ? link_path_walk+0x67/0x850
[79804.410354]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410368]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410390]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410392]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410394]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410397]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410399]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410401]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410403]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410407]  [<ffffffff81009f94>] ? fpu_finit+0x14/0x30
[79804.410409]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410411]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410413] INFO: task pppd:31897 blocked for more than 120 seconds.
[79804.410414] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410419] pppd            D ffff88015fd0cd00     0 31897  31800 0x00000004
[79804.410421]  ffff88014b1deb80 0000000000000082 ffff88014b1deb80
ffffffff8166e800
[79804.410424]  ffff88015901cb40 0000000000004000 ffff8801106dffd8
ffff8801106dffd8
[79804.410427]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410430] Call Trace:
[79804.410432]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410435]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410437]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410440]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410442]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410444]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410447]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410453]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410455]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410457]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410459]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410461]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410474] INFO: task pppd:31929 blocked for more than 120 seconds.
[79804.410476] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410477] pppd            D ffff88015fc0cd00     0 31929  31800 0x00000004
[79804.410480]  ffff88014b1deb80 0000000000000086 ffff88014b1deb80
ffffffff8166e800
[79804.410483]  ffff88014b192b00 0000000000004000 ffff88010d6fdfd8
ffff88010d6fdfd8
[79804.410486]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410488] Call Trace:
[79804.410490]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410493]  [<ffffffff810b94a7>] ? link_path_walk+0x67/0x850
[79804.410495]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410498]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410500]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410502]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410505]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410507]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410509]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410511]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410513]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410515]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410517] INFO: task pppd:31964 blocked for more than 120 seconds.
[79804.410519] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410520] pppd            D 0000000000000000     0 31964  31800 0x00000004
[79804.410522]  ffffffff8160b020 0000000000000086 ffffffff8107e2a9
ffffffff8166e800
[79804.410525]  ffff8801591260c0 0000000000004000 ffff88010b605fd8
ffff88010b605fd8
[79804.410528]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410530] Call Trace:
[79804.410533]  [<ffffffff8107e2a9>] ? __alloc_pages_nodemask+0x109/0x7c0
[79804.410540]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410542]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410544]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410547]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410549]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410551]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410554]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410556]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410558]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410560]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410562]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410564]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410566] INFO: task pppd:31993 blocked for more than 120 seconds.
[79804.410568] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410579] pppd            D 0000000000000000     0 31993  31800 0x00000004
[79804.410582]  ffffffff8160b020 0000000000000082 ffffffff8107e2a9
ffffffff8166e800
[79804.410585]  ffff8801590eb5c0 0000000000004000 ffff880107981fd8
ffff880107981fd8
[79804.410588]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410590] Call Trace:
[79804.410593]  [<ffffffff8107e2a9>] ? __alloc_pages_nodemask+0x109/0x7c0
[79804.410595]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410597]  [<ffffffff810b94a7>] ? link_path_walk+0x67/0x850
[79804.410599]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410601]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410604]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410606]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410608]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410611]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410613]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410615]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410617]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410619]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410624]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410626] INFO: task pppd:31994 blocked for more than 120 seconds.
[79804.410627] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410628] pppd            D ffff88015fd0cd00     0 31994  31800 0x00000000
[79804.410631]  ffff88015986cb40 0000000000000082 ffff88015986cb40
ffffffff8166e800
[79804.410634]  ffff8801590eab00 0000000000004000 ffff880156d41fd8
ffff880156d41fd8
[79804.410637]  0000000000000246 ffffffff8166e800 000280da8107f173
0000000000000000
[79804.410639] Call Trace:
[79804.410641]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410643]  [<ffffffff8107a0de>] ? find_get_pages+0x2e/0x120
[79804.410648]  [<ffffffff811802b3>] ? cpumask_any_but+0x23/0x40
[79804.410651]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410653]  [<ffffffff810218c5>] ? ptep_set_access_flags+0x25/0x30
[79804.410655]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410658]  [<ffffffffa0008624>] ? ppp_ioctl+0x2f4/0xf20 [ppp_generic]
[79804.410661]  [<ffffffff8101e2b8>] ? do_page_fault+0x198/0x460
[79804.410663]  [<ffffffff810c28be>] ? dput+0x1e/0x190
[79804.410678]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410680]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410683]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79804.410684] INFO: task pppd:31999 blocked for more than 120 seconds.
[79804.410686] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
message.
[79804.410687] pppd            D 0000000000000001     0 31999  31800 0x00000000
[79804.410690]  ffff88015986bb20 0000000000000082 0000000000002000
0000000000000000
[79804.410692]  ffff8801590ec080 0000000000004000 ffff88010b9e9fd8
ffff88010b9e9fd8
[79804.410695]  ffff88008c190500 ffff88010b9e9e88 00000010000000bb
ffff88008c190500
[79804.410698] Call Trace:
[79804.410701]  [<ffffffff81375e48>] ? sock_recvmsg+0xf8/0x140
[79804.410703]  [<ffffffff81375fd5>] ? sock_sendmsg+0xe5/0x120
[79804.410708]  [<ffffffff81082108>] ? release_pages+0x1d8/0x200
[79804.410711]  [<ffffffff81090cbe>] ? unmap_vmas+0x3fe/0x750
[79804.410714]  [<ffffffff814831b8>] ? __mutex_lock_slowpath+0xc8/0x140
[79804.410717]  [<ffffffff81482d3a>] ? mutex_lock+0x1a/0x40
[79804.410719]  [<ffffffffa00083bb>] ? ppp_ioctl+0x8b/0xf20 [ppp_generic]
[79804.410722]  [<ffffffff81484139>] ? _raw_spin_lock_bh+0x9/0x30
[79804.410725]  [<ffffffff81045fb4>] ? bit_waitqueue+0x14/0xa0
[79804.410728]  [<ffffffff810e3d30>] ? fsnotify_clear_marks_by_inode+0x20/0xd0
[79804.410730]  [<ffffffff810be1bf>] ? do_vfs_ioctl+0x8f/0x530
[79804.410732]  [<ffffffff810c296a>] ? dput+0xca/0x190
[79804.410735]  [<ffffffff810af57e>] ? fput+0x15e/0x220
[79804.410737]  [<ffffffff810be6a9>] ? sys_ioctl+0x49/0x80
[79804.410739]  [<ffffffff814848bb>] ? system_call_fastpath+0x16/0x1b
[79811.840094] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 138
[79821.980036] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 117
[79832.120019] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 96
[79842.260020] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 74
[79852.400168] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 52
[79862.540040] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 30
[79872.680037] unregister_netdevice: waiting for ppp618 to become free. Usage
count = 9

After this crash from dmesg i kill alll pppd services but users can not hang
need to restart server to back in work state.

After rebuild and back to old kernel 3.2.21 it has no problema
I run 1000 pppoe connection to one PPP server.


Best regards,
m.

--
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
