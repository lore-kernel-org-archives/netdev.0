From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth: WARNING: CPU: 1 PID: 25657 at include/net/sock.h:586 bt_sock_unlink+0x1c7/0x220()
Date: Thu, 21 Jan 2016 12:19:58 +0100
Message-ID: <90527994-751A-4BA4-93D4-63CEE4C40E6E@holtmann.org>
References: <5692B746.4050007@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.165.8.211] ([82.165.8.211]:56836 "EHLO mail.holtmann.org"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759365AbcAULUB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 06:20:01 -0500
In-Reply-To: <5692B746.4050007@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sasha,

> While fuzzing with trinity inside a KVM tools guest, running the latest -next
> kernel, I've hit the following warning:
> 
> [ 1153.249127] WARNING: CPU: 1 PID: 25657 at include/net/sock.h:586 bt_sock_unlink+0x1c7/0x220()
> [ 1153.250162] Modules linked in:
> [ 1153.250996] CPU: 1 PID: 25657 Comm: trinity-c223 Tainted: G        W       4.4.0-rc8-next-20160108-sasha-00024-gaaecb9a #2780
> [ 1153.252551]  1ffff100184f5f00 0000000015bfc733 ffff8800c27af880 ffffffff8301a182
> [ 1153.253594]  0000000041b58ab3 ffffffff8e1b3838 ffffffff8301a0b7 0000000015bfc733
> [ 1153.254857]  ffffffff8177f4c7 0000000015bfc733 ffff8801d16eb000 0000000000000001
> [ 1153.272107] Call Trace:
> [ 1153.272568] dump_stack (lib/dump_stack.c:52)
> [ 1153.274909] warn_slowpath_common (kernel/panic.c:484)
> [ 1153.276544] warn_slowpath_null (kernel/panic.c:518)
> [ 1153.277341] bt_sock_unlink (./arch/x86/include/asm/atomic.h:103 include/net/sock.h:577 include/net/sock.h:587 net/bluetooth/af_bluetooth.c:148)
> [ 1153.280581] hidp_sock_release (include/net/sock.h:1546 net/bluetooth/hidp/sock.c:43)
> [ 1153.281435] sock_release (net/socket.c:573)
> [ 1153.282145] sock_close (net/socket.c:1025)
> [ 1153.282874] __fput (fs/file_table.c:209)
> [ 1153.283581] ____fput (fs/file_table.c:245)
> [ 1153.296361] task_work_run (kernel/task_work.c:117 (discriminator 1))
> [ 1153.297090] do_exit (kernel/exit.c:749)
> [ 1153.302756] do_group_exit (kernel/exit.c:862)
> [ 1153.303523] get_signal (kernel/signal.c:2307)
> [ 1153.307151] do_signal (arch/x86/kernel/signal.c:781)
> [ 1153.322592] exit_to_usermode_loop (arch/x86/entry/common.c:249)
> [ 1153.323416] syscall_return_slowpath (./arch/x86/include/asm/jump_label.h:35 include/linux/context_tracking_state.h:30 include/linux/context_tracking.h:24 arch/x86/entry/common.c:284 arch/x86/entry/common.c:344)
> [ 1153.324276] int_ret_from_sys_call (arch/x86/entry/entry_64.S:282)

do you have a trinity command line that will reproduce this?

Regards

Marcel
