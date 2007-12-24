From: slavon@bigtelecom.ru
Subject: Re: Strange Panic (Deadlock)
Date: Mon, 24 Dec 2007 21:18:19 +0300
Message-ID: <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru>
References: <476FCC41.8070202@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:32797 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbXLXSSW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 13:18:22 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 18547A6C193
	for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 21:18:21 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aa8fMP3Dj2HX for <netdev@vger.kernel.org>;
	Mon, 24 Dec 2007 21:18:20 +0300 (MSK)
In-Reply-To: <476FCC41.8070202@bigtelecom.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again.
Its bug depend to
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=4aae07025265151e3f7041dfbf0f529e122de1d8
?
Its very critical bug to us. This PC must be HA. Server place so far  
for me to go and reboot server. I go to it 1-3 times in week =(
Please help to fix it =)

> Hello all. Some time machine freeze. No information on monitor. No
> rebooting on sysctl "kernel.panic".
> Any idea?
>
> Catched by netconsole:
> [91922.085864] ------------[ cut here ]------------
> [91922.085975] kernel BUG at kernel/timer.c:606!
> [91922.086058] invalid opcode: 0000 [#1]
> [91922.086127] SMP
> [91922.086201] Modules linked in: netconsole cls_u32 sch_sfq sch_htb
> xt_tcpudp iptable_filter ip_tables x_tables i2c_i801 i2c_core
> [91922.086386] CPU:    1
> [91922.086387] EIP:    0060:[<c0127387>]    Not tainted VLI
> [91922.086389] EFLAGS: 00010087   (2.6.23-gentoo-r4-fw #4)
> [91922.086600] EIP is at cascade+0x34/0x4f
> [91922.086669] eax: c0452200   ebx: f450408c   ecx: 00000022   edx: f3c6e08c
> [91922.086740] esi: 00000022   edi: c21ce000   ebp: 00000001   esp: c21c3ef8
> [91922.086815] ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
> [91922.086885] Process swapper (pid: 0, ti=c21c2000 task=c21af000
> task.ti=c21c2000)
> [91922.086954] Stack: f3c6e08c c21bfb74 00000000 c21ce000 0000000a
> c012767a c21af000 00000001
> [91922.087119]        c21c3f18 c0106963 c21c3f68 00000001 00000021
> c03c0b08 0000000a c0124556
> [91922.087285]        00000046 00000000 c21c2008 00000000 c01245ec
> c2015120 c0114a11 00000046
> [91922.087451] Call Trace:
> [91922.087586]  [<c012767a>] run_timer_softirq+0x51/0x154
> [91922.087669]  [<c0106963>] profile_pc+0x21/0x46
> [91922.087752]  [<c0124556>] __do_softirq+0x5d/0xc1
> [91922.087833]  [<c01245ec>] do_softirq+0x32/0x36
> [91922.087915]  [<c0114a11>] smp_apic_timer_interrupt+0x74/0x80
> [91922.087997]  [<c010484c>] apic_timer_interrupt+0x28/0x30
> [91922.088076]  [<c0102255>] mwait_idle_with_hints+0x3b/0x3f
> [91922.088162]  [<c0102259>] mwait_idle+0x0/0xa
> [91922.088237]  [<c0102398>] cpu_idle+0x91/0xaa
> [91922.088319]  =======================
> [91922.088390] Code: 08 8d 04 ca 8b 10 89 62 04 89 14 24 8b 50 04 89 22
> 89 00 89 54 24 04 8b 14 24 89 40 04 8b 1a eb 19 8b 42 14 83 e0 fe 39 f8
> 74 04 <0f> 0b eb fe 89 f8 e8 d8 fe ff ff 89 da 8b 1b 39 e2 75 e3 59 89
> [91922.088864] EIP: [<c0127387>] cascade+0x34/0x4f SS:ESP 0068:c21c3ef8
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

