From: "jianhai yang" <jianhai@gmail.com>
Subject: Is there any patch for this problem?
Date: Fri, 25 Jul 2008 10:32:30 +0800
Message-ID: <9f281e550807241932w7b0a5a25rd04aecb0a69e9363@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:35349 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbYGYCcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 22:32:31 -0400
Received: by wr-out-0506.google.com with SMTP id 69so2101180wri.5
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 19:32:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using PPP currently, but sometimes the process "pppd" becomes
UNINTERRUPTIBLE while the serial port is still active. My kernel is
linux-2.6.21.
For now I have got the short message from "dmesg" as bellow:


[ 1398.270000] [<c00b05f8>] (raw_notifier_call_chain+0x0/0x14) from
[<c025b3c8>] (unregister_netdevice+0x1a0/0x294)
[ 1398.270000] [<c025b228>] (unregister_netdevice+0x0/0x294) from
[<c025b4dc>] (unregister_netdev+0x20/0x28)
[ 1398.270000]  r6 = C159C800  r5 = C1B5F400  r4 = C1B5F400
[ 1398.270000] [<c025b4bc>] (unregister_netdev+0x0/0x28) from
[<c01ea1f4>] (ppp_shutdown_interface+0x7c/0xc8)
[ 1398.270000]  r4 = C0EEC000
[ 1398.270000] [<c01ea178>] (ppp_shutdown_interface+0x0/0xc8) from
[<c01ea5a0>] (ppp_release+0x44/0x9c)
[ 1398.270000]  r7 = C13D7238  r6 = C13AB638  r5 = 00000008  r4 = C159C800
[ 1398.270000] [<c01ea55c>] (ppp_release+0x0/0x9c) from [<c00ec010>]
(__fput+0xb8/0x1b4)
[ 1398.270000]  r4 = C1674840
[ 1398.270000] [<c00ebf58>] (__fput+0x0/0x1b4) from [<c00ec274>]
(fput+0x34/0x38)
[ 1398.270000]  r8 = 00000001  r7 = C202DDE0  r6 = 00000000  r5 = C07EC380
[ 1398.270000]  r4 = C1674840
[ 1398.270000] [<c00ec240>] (fput+0x0/0x38) from [<c00e9054>]
(filp_close+0x78/0x84)
[ 1398.270000] [<c00e8fdc>] (filp_close+0x0/0x84) from [<c00a32c4>]
(put_files_struct+0x88/0xe0)
[ 1398.270000]  r6 = 000000D4  r5 = 0000077F  r4 = C07EC380
[ 1398.270000] [<c00a323c>] (put_files_struct+0x0/0xe0) from
[<c00a486c>] (do_exit+0x248/0x90c)
[ 1398.270000]  r8 = 00000009  r7 = 00000001  r6 = C0EEDFB0  r5 = C07EB320
[ 1398.270000]  r4 = C07EC380
[ 1398.270000] [<c00a4624>] (do_exit+0x0/0x90c) from [<c00a4ff4>]
(do_group_exit+0xc4/0xcc)
[ 1398.270000] [<c00a4f30>] (do_group_exit+0x0/0xcc) from [<c00af814>]
(get_signal_to_deliver+0x3e0/0x42c)
[ 1398.270000]  r4 = C3581B54
[ 1398.270000] [<c00af434>] (get_signal_to_deliver+0x0/0x42c) from
[<c0080a48>] (do_signal+0x64/0x4d4)
[ 1398.270000] [<c00809e4>] (do_signal+0x0/0x4d4) from [<c0080ee4>]
(do_notify_resume+0x2c/0x30)
[ 1398.270000] [<c0080eb8>] (do_notify_resume+0x0/0x30) from
[<c007dd0c>] (work_pending+0x1c/0x20)
[ 1398.270000] Code: e1a0c00d e92dd810 e24cb004 e24dd004 (e5904014)
[ 1398.810000] Fixing recursive fault but reboot is needed!


Thanks a lot!



Best Regards!
                                                  Jianhai Yang.
