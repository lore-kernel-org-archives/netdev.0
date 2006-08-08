From: Dave Jones <davej@redhat.com>
Subject: another networking lockdep trace.
Date: Tue, 8 Aug 2006 14:41:57 -0400
Message-ID: <20060808184157.GB4880@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qcHopEYAB45HaUaB"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32701 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965028AbWHHSmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 14:42:09 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k78Ig8og019249
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 14:42:08 -0400
Received: from nwo.kernelslacker.org (vpn-248-3.boston.redhat.com [10.13.248.3])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k78Ifv6S026419
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 14:41:58 -0400
Received: from nwo.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by nwo.kernelslacker.org (8.13.7/8.13.5) with ESMTP id k78Ifvkr014007
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 14:41:57 -0400
Received: (from davej@localhost)
	by nwo.kernelslacker.org (8.13.7/8.13.7/Submit) id k78IfvHQ014006
	for netdev@vger.kernel.org; Tue, 8 Aug 2006 14:41:57 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

>From a recent rc3-git kernel.

		Dave

-- 
http://www.codemonkey.org.uk

--qcHopEYAB45HaUaB
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <kernel-maint-admin@redhat.com>
X-Spam-Checker-Version: SpamAssassin 3.1.3 (2006-06-01) on
	nwo.kernelslacker.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=5.0 tests=AWL,BAYES_00,NO_REAL_NAME,
	UNPARSEABLE_RELAY autolearn=no version=3.1.3
Received: from pobox.devel.redhat.com [10.11.255.8]
	by nwo.kernelslacker.org with IMAP (fetchmail-6.3.4)
	for <davej@localhost> (single-drop); Mon, 07 Aug 2006 10:07:59 -0400 (EDT)
Received: from pobox.devel.redhat.com ([unix socket])
	 by pobox.devel.redhat.com (Cyrus v2.2.12-Invoca-RPM-2.2.12-3.RHEL4.1) with LMTPA;
	 Mon, 07 Aug 2006 10:07:24 -0400
X-Sieve: CMU Sieve 2.2
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by pobox.devel.redhat.com (8.13.1/8.13.1) with ESMTP id k77E7NKw025351;
	Mon, 7 Aug 2006 10:07:23 -0400
Received: from post-office.corp.redhat.com (post-office.corp.redhat.com [172.16.52.227])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k77E7MOV001722;
	Mon, 7 Aug 2006 10:07:22 -0400
Received: from post-office.corp.redhat.com (localhost.localdomain [127.0.0.1])
	by post-office.corp.redhat.com (8.11.6/8.11.6) with ESMTP id k77E7MR10480;
	Mon, 7 Aug 2006 10:07:22 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by post-office.corp.redhat.com (8.11.6/8.11.6) with ESMTP id k77DtcR08181
	for <kernel-maint@post-office.corp.redhat.com>; Mon, 7 Aug 2006 09:55:38 -0400
Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k77DtcYJ030430
	for <kernel-maint@redhat.com>; Mon, 7 Aug 2006 09:55:38 -0400
Received: from bugzilla.redhat.com (bugzilla.redhat.com [172.16.48.198])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k77DtccZ029514
	for <kernel-maint@redhat.com>; Mon, 7 Aug 2006 09:55:38 -0400
Received: from bugzilla.redhat.com (localhost.localdomain [127.0.0.1])
	by bugzilla.redhat.com (8.13.1/8.13.1) with ESMTP id k77Dtcqh014096
	for <kernel-maint@redhat.com>; Mon, 7 Aug 2006 09:55:38 -0400
Received: (from apache@localhost)
	by bugzilla.redhat.com (8.13.1/8.12.11/Submit) id k77Dtcvg014095;
	Mon, 7 Aug 2006 09:55:38 -0400
From: bugzilla@redhat.com
To: kernel-maint@redhat.com
Subject: [Bug 201560] New: INFO: inconsistent lock state - during boot .2528
Content-type: text/plain; charset=utf-8
Message-ID: <bug-201560-176318@bugzilla.redhat.com>
X-Loop: bugzilla@redhat.com
X-BeenThere: bugzilla@redhat.com
X-Bugzilla-Product: Fedora Core
X-Bugzilla-Version: devel
X-Bugzilla-Component: kernel
X-Bugzilla-Comment: Public
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Changed-Fields: New
Sender: kernel-maint-admin@redhat.com
Errors-To: kernel-maint-admin@redhat.com
X-BeenThere: kernel-maint@redhat.com
X-Mailman-Version: 2.0.13
Precedence: bulk
List-Help: <mailto:kernel-maint-request@redhat.com?subject=help>
List-Post: <mailto:kernel-maint@redhat.com>
List-Subscribe: <http://post-office.corp.redhat.com/mailman/listinfo/kernel-maint>,
	<mailto:kernel-maint-request@redhat.com?subject=subscribe>
List-Id: <kernel-maint.redhat.com>
List-Unsubscribe: <http://post-office.corp.redhat.com/mailman/listinfo/kernel-maint>,
	<mailto:kernel-maint-request@redhat.com?subject=unsubscribe>
List-Archive: <http://post-office.corp.redhat.com/mailman/private/kernel-maint/>
Date: Mon, 7 Aug 2006 09:55:38 -0400

Please do not reply directly to this email. All additional
comments should be made in the comments box of this bug report.




https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=201560

           Summary: INFO: inconsistent lock state - during boot .2528
           Product: Fedora Core
           Version: devel
          Platform: All
        OS/Version: Linux
            Status: NEW
          Severity: normal
          Priority: normal
         Component: kernel
        AssignedTo: kernel-maint@redhat.com
        ReportedBy: selinux@gmail.com
         QAContact: bbrock@redhat.com
                CC: wtogami@redhat.com


Description of problem:
Get this on boot of new kernel:

Aug  7 06:47:44 localhost kernel: [ INFO: inconsistent lock state ]
Aug  7 06:47:44 localhost pcscd: winscard.c:219:SCardConnect() Reader E-Gate 0 0
Not Found
Aug  7 06:47:44 localhost kernel: ---------------------------------
Aug  7 06:47:44 localhost kernel: inconsistent {in-softirq-W} -> {softirq-on-W}
usage.
Aug  7 06:47:44 localhost kernel: ip/2617 [HC0[0]:SC0[0]:HE1:SE1] takes:
Aug  7 06:47:44 localhost kernel:  (&ifa->lock){-+..}, at: [<f90a3836>]
inet6_addr_add+0xf8/0x13e [ipv6]
Aug  7 06:47:44 localhost kernel: {in-softirq-W} state was registered at:
Aug  7 06:47:44 localhost kernel:   [<c043bfb9>] lock_acquire+0x4b/0x6a
Aug  7 06:47:44 localhost kernel:   [<c060f428>] _spin_lock_bh+0x1e/0x2d
Aug  7 06:47:44 localhost kernel:   [<f90a4757>] addrconf_dad_timer+0x3a/0xe2 [ipv6]
Aug  7 06:47:44 localhost pcscd: winscard.c:219:SCardConnect() Reader E-Gate 0 0
Not Found
Aug  7 06:47:44 localhost kernel:   [<c042dbc0>] run_timer_softirq+0x108/0x167
Aug  7 06:47:44 localhost kernel:   [<c04293ab>] __do_softirq+0x78/0xf2
Aug  7 06:47:44 localhost kernel:   [<c0406673>] do_softirq+0x5a/0xbe
Aug  7 06:47:44 localhost kernel: irq event stamp: 3551
Aug  7 06:47:44 localhost kernel: hardirqs last  enabled at (3551): [<c04291bf>]
local_bh_enable_ip+0xc6/0xcf
Aug  7 06:47:45 localhost kernel: hardirqs last disabled at (3549): [<c0429152>]
local_bh_enable_ip+0x59/0xcf
Aug  7 06:47:45 localhost kernel: softirqs last  enabled at (3550): [<f90a09ce>]
ipv6_add_addr+0x210/0x254 [ipv6]
Aug  7 06:47:45 localhost kernel: softirqs last disabled at (3538): [<c060f4f7>]
_read_lock_bh+0xb/0x2d
Aug  7 06:47:45 localhost kernel:
Aug  7 06:47:45 localhost kernel: other info that might help us debug this:
Aug  7 06:47:45 localhost kernel: 1 lock held by ip/2617:
Aug  7 06:47:45 localhost kernel:  #0:  (rtnl_mutex){--..}, at: [<c060e378>]
mutex_lock+0x21/0x24
Aug  7 06:47:45 localhost kernel:
Aug  7 06:47:45 localhost kernel: stack backtrace:
Aug  7 06:47:45 localhost kernel:  [<c04051ee>] show_trace_log_lvl+0x58/0x159
Aug  7 06:47:45 localhost kernel:  [<c04057ea>] show_trace+0xd/0x10
Aug  7 06:47:45 localhost kernel:  [<c0405903>] dump_stack+0x19/0x1b
Aug  7 06:47:45 localhost kernel:  [<c043a402>] print_usage_bug+0x1ca/0x1d7
Aug  7 06:47:45 localhost kernel:  [<c043a8eb>] mark_lock+0x239/0x353
Aug  7 06:47:45 localhost kernel:  [<c043b50a>] __lock_acquire+0x459/0x997
Aug  7 06:47:45 localhost kernel:  [<c043bfb9>] lock_acquire+0x4b/0x6a
Aug  7 06:47:45 localhost kernel:  [<c060f3fb>] _spin_lock+0x19/0x28
Aug  7 06:47:45 localhost kernel:  [<f90a3836>] inet6_addr_add+0xf8/0x13e [ipv6]
Aug  7 06:47:45 localhost kernel:  [<f90a3a39>] inet6_rtm_newaddr+0x1bd/0x1d2 [ipv6]
Aug  7 06:47:45 localhost kernel:  [<c05bf5f3>] rtnetlink_rcv_msg+0x1b3/0x1d6
Aug  7 06:47:45 localhost kernel:  [<c05cae7b>] netlink_run_queue+0x69/0xfe
Aug  7 06:47:45 localhost kernel:  [<c05bf3f6>] rtnetlink_rcv+0x29/0x42
Aug  7 06:47:45 localhost kernel:  [<c05cb308>] netlink_data_ready+0x12/0x50
Aug  7 06:47:45 localhost kernel:  [<c05ca370>] netlink_sendskb+0x1f/0x37
Aug  7 06:47:45 localhost kernel:  [<c05cac49>] netlink_unicast+0x1a1/0x1bb
Aug  7 06:47:45 localhost kernel:  [<c05cb2e9>] netlink_sendmsg+0x275/0x282
Aug  7 06:47:45 localhost kernel:  [<c05ae91a>] sock_sendmsg+0xe8/0x103
Aug  7 06:47:45 localhost kernel:  [<c05af129>] sys_sendmsg+0x14d/0x1a8
Aug  7 06:47:45 localhost kernel:  [<c05b02fb>] sys_socketcall+0x16b/0x186
Aug  7 06:47:45 localhost kernel:  [<c0403faf>] syscall_call+0x7/0xb
Aug  7 06:47:45 localhost kernel: DWARF2 unwinder stuck at syscall_call+0x7/0xb
Aug  7 06:47:45 localhost kernel: Leftover inexact backtrace:
Aug  7 06:47:45 localhost avahi-daemon[2392]: New relevant interface eth0.IPv6
for mDNS.
Aug  7 06:47:45 localhost kernel:  [<c04057ea>] show_trace+0xd/0x10
Aug  7 06:47:45 localhost avahi-daemon[2392]: Joining mDNS multicast group on
interface eth0.IPv6 with address fe80::20a:e4ff:fe3f:8bc4.
Aug  7 06:47:45 localhost kernel:  [<c0405903>] dump_stack+0x19/0x1b
Aug  7 06:47:45 localhost avahi-daemon[2392]: Registering new address record for
fe80::20a:e4ff:fe3f:8bc4 on eth0.
Aug  7 06:47:45 localhost kernel:  [<c043a402>] print_usage_bug+0x1ca/0x1d7
Aug  7 06:47:45 localhost kernel:  [<c043a8eb>] mark_lock+0x239/0x353
Aug  7 06:47:45 localhost kernel:  [<c043b50a>] __lock_acquire+0x459/0x997
Aug  7 06:47:45 localhost kernel:  [<c043bfb9>] lock_acquire+0x4b/0x6a
Aug  7 06:47:45 localhost kernel:  [<c060f3fb>] _spin_lock+0x19/0x28
Aug  7 06:47:45 localhost kernel:  [<f90a3836>] inet6_addr_add+0xf8/0x13e [ipv6]
Aug  7 06:47:45 localhost kernel:  [<f90a3a39>] inet6_rtm_newaddr+0x1bd/0x1d2 [ipv6]
Aug  7 06:47:45 localhost kernel:  [<c05bf5f3>] rtnetlink_rcv_msg+0x1b3/0x1d6
Aug  7 06:47:45 localhost kernel:  [<c05cae7b>] netlink_run_queue+0x69/0xfe
Aug  7 06:47:45 localhost kernel:  [<c05bf3f6>] rtnetlink_rcv+0x29/0x42
Aug  7 06:47:45 localhost kernel:  [<c05cb308>] netlink_data_ready+0x12/0x50
Aug  7 06:47:45 localhost kernel:  [<c05ca370>] netlink_sendskb+0x1f/0x37
Aug  7 06:47:45 localhost kernel:  [<c05cac49>] netlink_unicast+0x1a1/0x1bb
Aug  7 06:47:45 localhost kernel:  [<c05cb2e9>] netlink_sendmsg+0x275/0x282
Aug  7 06:47:45 localhost kernel:  [<c05ae91a>] sock_sendmsg+0xe8/0x103
Aug  7 06:47:45 localhost kernel:  [<c05af129>] sys_sendmsg+0x14d/0x1a8
Aug  7 06:47:45 localhost kernel:  [<c05b02fb>] sys_socketcall+0x16b/0x186
Aug  7 06:47:45 localhost kernel:  [<c0403faf>] syscall_call+0x7/0xb
Aug  7 06:47:47 localhost kernel: [drm] Initialized drm 1.0.1 20051102
Aug  7 06:47:47 localhost kernel: ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 16
(level, low) -> IRQ 177
Aug  7 06:47:47 localhost kernel: [drm] Initialized i915 1.5.0 20060119 on minor 0
Aug  7 06:48:08 localhost audispd: s == 0


Version-Release number of selected component (if applicable):
kernel-2.6.17-1.2528.fc6

How reproducible:


Steps to Reproduce:
1. boot
2.
3.
  
Actual results:


Expected results:


Additional info:

-- 
Configure bugmail: https://bugzilla.redhat.com/bugzilla/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--qcHopEYAB45HaUaB--
