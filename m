From: Klemen Mihevc <solor@mihgroup.net>
Subject: hw csum error since =?UTF-8?Q?=33=2E=31=36=E2=80=8F?=
Date: Tue, 07 Oct 2014 12:54:01 +0200
Message-ID: <92a37c19e2fb42a308fdd5acf107b12f@mihgroup.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 84-255-207-212.static.t-2.net ([84.255.207.212]:48894 "EHLO
	smtp.mihgroup.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbaJGK7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 06:59:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 3.16.0 (also present in 3.17.0) kernel im geting following error 
in my kern.log

Aug 15 14:51:00 mih kernel: <unknown>: hw csum failure
Aug 15 14:51:00 mih kernel: CPU: 0 PID: 5543 Comm: named Not tainted 
3.16.1-gentoo #1
Aug 15 14:51:00 mih kernel: Hardware name: stem manufacturer System 
Product Name/P5LD2, BIOS 2002    08/28/2009
Aug 15 14:51:00 mih kernel: c16e4bba c14ab6db 00000000 f1b29d20 ffff43fa 
00000008 87d4782b f5a31200
Aug 15 14:51:00 mih kernel: f1b1dc80 f1b29f24 0000005a c15e13b1 f1b29d58 
f1b29d5c 00000000 0000005a
Aug 15 14:51:00 mih kernel: 00000000 f1b29d78 f1b1dec0 00000000 00000000 
f1e3f600 00000040 f1b29f24
Aug 15 14:51:00 mih kernel: Call Trace:
Aug 15 14:51:00 mih kernel: [<c16e4bba>] ? dump_stack+0xa/0x13
Aug 15 14:51:00 mih kernel: [<c14ab6db>] ? 
skb_copy_and_csum_datagram_iovec+0xe5/0xea
Aug 15 14:51:00 mih kernel: [<c15e13b1>] ? udpv6_recvmsg+0xd9/0x4f7
Aug 15 14:51:00 mih kernel: [<c158efde>] ? inet_recvmsg+0x3e/0x50
Aug 15 14:51:00 mih kernel: [<c149f2d3>] ? sock_recvmsg+0x60/0x80
Aug 15 14:51:00 mih kernel: [<c14aa367>] ? verify_iovec+0x35/0x9e
Aug 15 14:51:00 mih kernel: [<c149f273>] ? kernel_sendmsg+0x34/0x34
Aug 15 14:51:00 mih kernel: [<c14a030e>] ? 
___sys_recvmsg.part.33+0xe6/0x175
Aug 15 14:51:00 mih kernel: [<c149f273>] ? kernel_sendmsg+0x34/0x34
Aug 15 14:51:00 mih kernel: [<c1093cae>] ? futex_wait+0x12e/0x1e1
Aug 15 14:51:00 mih kernel: [<c1583ce5>] ? 
ip4_datagram_connect+0x1e6/0x281
Aug 15 14:51:00 mih kernel: [<c108304a>] ? __wake_up_common+0x3f/0x66
Aug 15 14:51:00 mih kernel: [<c109390c>] ? get_futex_key+0x164/0x1d6
Aug 15 14:51:00 mih kernel: [<c1093a97>] ? futex_wake+0xcc/0xf3
Aug 15 14:51:00 mih kernel: [<c10f5982>] ? __fget_light+0x19/0x49
Aug 15 14:51:00 mih kernel: [<c14a1098>] ? __sys_recvmsg+0x44/0x6c
Aug 15 14:51:00 mih kernel: [<c14a142f>] ? SyS_socketcall+0xdf/0x2e6
Aug 15 14:51:00 mih kernel: [<c108b72d>] ? __getnstimeofday+0x2c/0x109
Aug 15 14:51:00 mih kernel: [<c10676ea>] ? SyS_gettimeofday+0x26/0x5e
Aug 15 14:51:00 mih kernel: [<c16e9fd1>] ? syscall_call+0x7/0x7
Aug 15 14:51:00 mih kernel: [<c16e0000>] ? soft_store+0x3b/0x6e

I guess it something related to my hardware/network. Everything seems to 
work fine tho... just error poping out every few minutes. Its kinda 
random, sometimes time between is ~5min, sometimes 30sec... If i boot 
with old kernel (3.15.8) this error is gone. If you need anything else i 
can provide config etc, but since this seems like somekind of trace i 
tought its enough :)

Also filled in a bug on bugzilla 
(https://bugzilla.kernel.org/show_bug.cgi?id=82461)

Thanks
