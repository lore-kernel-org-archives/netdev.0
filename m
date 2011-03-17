From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 31282] New: Kernel panic . tcp_input.c:3317
Date: Thu, 17 Mar 2011 09:46:01 -0700
Message-ID: <20110317094601.3a1748d0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57258 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab1CQQqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 12:46:04 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id C75301829774
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 09:46:03 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id P1HgfLXmqIrt for <netdev@vger.kernel.org>;
	Thu, 17 Mar 2011 09:46:02 -0700 (PDT)
Received: from nehalam (pool-74-107-135-205.ptldor.fios.verizon.net [74.107.135.205])
	by mail.vyatta.com (Postfix) with ESMTPSA id 66C051829411
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 09:46:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 17 Mar 2011 10:19:56 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 31282] New: Kernel panic . tcp_input.c:3317


https://bugzilla.kernel.org/show_bug.cgi?id=31282

           Summary: Kernel panic . tcp_input.c:3317
           Product: Networking
           Version: 2.5
    Kernel Version: Linux version 2.6.32-28-generic (buildd@palmer) (gcc
                    version 4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #55-Ubuntu SMP
                    Mon Jan 10 21:21:01 UTC 2011 (Ubuntu
                    2.6.32-28.55-generic 2.6.32.27+drm33.12)
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: vitaliy.migov@boldendeavours.com
        Regression: No


Mar  1 12:07:24 Securus kernel: [1036627.396040] ------------[ cut here
]------------
Mar  1 12:07:24 Securus kernel: [1036627.396049] WARNING: at
/build/buildd/linux-2.6.32/net/ipv4/tcp_input.c:3317
tcp_clean_rtx_queue+0x6b8/0x7b0()
Mar  1 12:07:24 Securus kernel: [1036627.396051] Hardware name: OEM
Mar  1 12:07:24 Securus kernel: [1036627.396052] Modules linked in: binfmt_misc
ipt_REDIRECT iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4
xt_tcpudp iptable_filter ip_tables x_tables fbcon tileblit font bitblit
softcursor vga16fb vgastate i915 ppdev drm_kms_helper parport_pc serio_raw drm
i2c_algo_bit video lp output intel_agp agpgart parport e1000e
Mar  1 12:07:24 Securus kernel: [1036627.396075] Pid: 1589, comm: mysqld Not
tainted 2.6.32-28-generic #55-Ubuntu
Mar  1 12:07:24 Securus kernel: [1036627.396077] Call Trace:
Mar  1 12:07:24 Securus kernel: [1036627.396082]  [<c014c892>]
warn_slowpath_common+0x72/0xa0
Mar  1 12:07:24 Securus kernel: [1036627.396085]  [<c0503038>] ?
tcp_clean_rtx_queue+0x6b8/0x7b0
Mar  1 12:07:24 Securus kernel: [1036627.396087]  [<c0503038>] ?
tcp_clean_rtx_queue+0x6b8/0x7b0
Mar  1 12:07:24 Securus kernel: [1036627.396091]  [<c052bc50>] ?
bictcp_acked+0x0/0x180
Mar  1 12:07:24 Securus kernel: [1036627.396093]  [<c014c8da>]
warn_slowpath_null+0x1a/0x20
Mar  1 12:07:24 Securus kernel: [1036627.396096]  [<c0503038>]
tcp_clean_rtx_queue+0x6b8/0x7b0
Mar  1 12:07:24 Securus kernel: [1036627.396099]  [<c013fb83>] ?
finish_task_switch+0x43/0xc0
Mar  1 12:07:24 Securus kernel: [1036627.396102]  [<c050332d>]
tcp_ack+0x1fd/0x640
Mar  1 12:07:24 Securus kernel: [1036627.396105]  [<c0504177>]
tcp_rcv_established+0x4e7/0x670
Mar  1 12:07:24 Securus kernel: [1036627.396108]  [<c04b843c>] ?
release_sock+0x9c/0xb0
Mar  1 12:07:24 Securus kernel: [1036627.396111]  [<c050b0ed>]
tcp_v4_do_rcv+0xbd/0x130
Mar  1 12:07:24 Securus kernel: [1036627.396113]  [<c04f8942>]
tcp_prequeue_process+0x62/0x80
Mar  1 12:07:24 Securus kernel: [1036627.396116]  [<c04fb24c>]
tcp_recvmsg+0x8fc/0xbe0
Mar  1 12:07:24 Securus kernel: [1036627.396119]  [<c058e8e6>] ?
_spin_unlock_bh+0x16/0x20
Mar  1 12:07:24 Securus kernel: [1036627.396121]  [<c04b843c>] ?
release_sock+0x9c/0xb0
Mar  1 12:07:24 Securus kernel: [1036627.396124]  [<c04f88aa>] ?
tcp_push+0x7a/0xb0
Mar  1 12:07:24 Securus kernel: [1036627.396127]  [<c04b7c28>]
sock_common_recvmsg+0x48/0x60
Mar  1 12:07:24 Securus kernel: [1036627.396130]  [<c04b7884>]
sock_aio_read+0x124/0x130
Mar  1 12:07:24 Securus kernel: [1036627.396134]  [<c0209164>]
do_sync_read+0xc4/0x100
Mar  1 12:07:24 Securus kernel: [1036627.396137]  [<c0167be0>] ?
autoremove_wake_function+0x0/0x50
Mar  1 12:07:24 Securus kernel: [1036627.396140]  [<c0144c79>] ?
run_rebalance_domains+0x39/0xc0
Mar  1 12:07:24 Securus kernel: [1036627.396144]  [<c02f6544>] ?
security_file_permission+0x14/0x20
Mar  1 12:07:24 Securus kernel: [1036627.396147]  [<c0209204>] ?
rw_verify_area+0x64/0xe0
Mar  1 12:07:24 Securus kernel: [1036627.396149]  [<c0209be2>]
vfs_read+0x182/0x1a0
Mar  1 12:07:24 Securus kernel: [1036627.396152]  [<c0216c7d>] ?
do_fcntl+0xad/0x360
Mar  1 12:07:24 Securus kernel: [1036627.396154]  [<c0355309>] ?
copy_to_user+0x39/0x130
Mar  1 12:07:24 Securus kernel: [1036627.396157]  [<c0209cb2>]
sys_read+0x42/0x70
Mar  1 12:07:24 Securus kernel: [1036627.396160]  [<c01033ec>]
syscall_call+0x7/0xb
Mar  1 12:07:24 Securus kernel: [1036627.396162] ---[ end trace
a54f02b2f089b137 ]---

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
