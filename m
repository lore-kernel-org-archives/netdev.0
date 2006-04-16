From: "Saurabh Jain" <jassduec@gmail.com>
Subject: Kernel error
Date: Sun, 16 Apr 2006 01:43:08 -0500
Message-ID: <3a1eedb70604152343u2f720781o40fbd910f6558041@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.193]:19928 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751230AbWDPGnI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2006 02:43:08 -0400
Received: by nz-out-0102.google.com with SMTP id o37so363217nzf
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2006 23:43:08 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guys,

I am getting the following kernel error while doing some experiments.
Any idea where things are going wrong. To me it looks like there is an
error while copying data from user space to kernel space. The
application which i am running is iperf. However i also have netem
module for emulating some wide area network characteristics like
delay. I am using delay of 100ms.

##################Error Message#############################
Unable to handle kernel NULL pointer dereference at virtual address 00000004
 printing eip:
c02fee3c
*pde = 7ded4067
Oops: 0002 [#5]
Modules linked in: setparam(U) sch_netem(U) nfs(U) lockd(U) autofs4(U)
sunrpc(U)CPU:    0
EIP:    0060:[<c02fee3c>]    Not tainted VLI
EFLAGS: 00010286   (2.6.12-1.1390_FC4-emulab-1)
EIP is at tcp_transmit_skb+0x3ef/0x8de
eax: 00000000   ebx: f71a1a40   ecx: ed64f960   edx: ed64ff60
esi: 00000000   edi: f2f98500   ebp: ed71b780   esp: f47bddd4
ds: 007b   es: 007b   ss: 0068
Process iperf (pid: 2443, threadinfo=f47bc000 task=f71a1a40)
Stack: f2f9854c c02d1019 ed71b7b8 f2f98500 ed15cc80 00000282 ed71b780 00000100
       c02ce99f f71a1a40 f2f98500 f71a1a40 00000000 f2f98500 f2f9854c c02f53ad
       00000000 ed335db8 f2f98500 f2f98500 f47bdeb8 00000000 00000000 002ce99f
Call Trace:
 [<c02d1019>] skb_copy_datagram_iovec+0x180/0x1f8
 [<c02ce99f>] alloc_skb+0x31/0xc1
 [<c02f53ad>] tcp_recvmsg+0x2b1/0x74e
 [<c02fd83f>] tcp_rcv_established+0x5d2/0x77a
 [<c02ce2e0>] sock_common_recvmsg+0x41/0x57
 [<c02cb052>] sock_aio_read+0xf9/0x12b
 [<c014fccb>] do_sync_read+0x9e/0xec
 [<c01291ae>] autoremove_wake_function+0x0/0x37
 [<c014fe23>] vfs_read+0x10a/0x10e
 [<c0150064>] sys_read+0x41/0x6a
 [<c0102d29>] syscall_call+0x7/0xb
Code: a1 04 07 39 c0 e8 c0 e5 e3 ff 89 c2 85 c0 74 2d 83 87 08 04 00 00 01 8b 8
#############################################################

Thanks in advance
