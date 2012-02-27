From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:3418
Date: Sun, 26 Feb 2012 16:10:04 -0800 (PST)
Message-ID: <alpine.DEB.2.01.1202261609060.4930@trent.utfs.org>
References: <alpine.DEB.2.01.1202261556150.4930@trent.utfs.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: markus@trippelsdorf.de, ncardwell@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from trent.utfs.org ([94.185.90.103]:43882 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004Ab2B0ATY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Feb 2012 19:19:24 -0500
In-Reply-To: <alpine.DEB.2.01.1202261556150.4930@trent.utfs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Cc'ing Neal, as he was the last one touching net/ipv4/tcp_input.c :-) ]

On Sun, 26 Feb 2012 at 16:05, Christian Kujau wrote:
> Hi,
> 
> I'm getting the same message here on PowerPC (32bit):
> 
> ------------[ cut here ]------------
> WARNING: at /usr/local/src/linux-2.6-git/net/ipv4/tcp_input.c:3418
> Modules linked in: tun nfs ecryptfs netconsole therm_adt746x aes_generic 
> arc4 b43 i2c_powermac sd_mod firewire_sbp2 mac80211 cfg80211 usb_storage 
> scsi_mod
> NIP: c04720c4 LR: c04720b8 CTR: c049f2c8
> REGS: efff1c20 TRAP: 0700   Tainted: G        W     (3.3.0-rc4)
> MSR: 00029032 <EE,ME,IR,DR,RI>  CR: 42048448  XER: 20000000
> TASK = ee666780[1964] 'milkyway_0.50_p' THREAD: ee6c6000
> GPR00: ffffffff efff1cd0 ee666780 ee70c0a0 0000000b ffffffff c0426e70 00000000 
> GPR08: 0000000b 00000001 00000000 00000009 42048448 1013488c 00000000 4f4a260f 
> GPR16: 29c2cc42 00000502 00000000 000001cb 000001cb ee70c1b0 0000000b 00000000 
> GPR24: 00000001 0000000c ffffffff ecef8580 0000000b 3c176da7 ee70c0a0 c0690000 
> NIP [c04720c4] tcp_ack+0x720/0x10a0
> LR [c04720b8] tcp_ack+0x714/0x10a0
> Call Trace:
> [efff1cd0] [c04720b8] tcp_ack+0x714/0x10a0 (unreliable)
> [efff1d60] [c04756f0] tcp_rcv_established+0x214/0x6c4
> [efff1d90] [c047d1dc] tcp_v4_do_rcv+0xd8/0x2a4
> [efff1dd0] [c047db0c] tcp_v4_rcv+0x764/0x8e4
> [efff1e10] [c045ac6c] ip_local_deliver+0xe0/0x1dc
> [efff1e30] [c045a870] ip_rcv+0x378/0x694
> [efff1e50] [c04302c8] __netif_receive_skb+0x320/0x52c
> [efff1eb0] [c0430790] napi_skb_finish+0x6c/0x90
> [efff1ec0] [c03b2e20] gem_poll+0x694/0x1274
> [efff1f50] [c0430ccc] net_rx_action+0x1d4/0x278
> [efff1fa0] [c003bac0] __do_softirq+0xf4/0x1bc
> [efff1ff0] [c00103b0] call_do_softirq+0x14/0x24
> [ee6c7ee0] [c00070ac] do_softirq+0xfc/0x128
> [ee6c7f00] [c003b73c] irq_exit+0xac/0xcc
> [ee6c7f10] [c00071d8] do_IRQ+0x8c/0x1b0
> [ee6c7f40] [c0012e60] ret_from_except+0x0/0x14
> Instruction dump:
> 2f800000 419e0020 73250008 4182046c 38a0ffff 7ec4b378 7fc3f378 7c0903a6 
> 4e800421 801e04e8 7c1a0378 54090ffe <0f090000> 809e04e4 54890ffe 0f090000 
> ---[ end trace de136ca1488e7a83 ]---
> Leak s=4294967295 1
> 
> 
> Yesterday the machine panick'ed and shutdown shortly after the message 
> appeared. From today's logs I can see the message appeared some 10 hours 
> ago but the machine is still up & running. I've been running 3.3.0-rc4 for 
> some time now, but network activity went up a few days ago, so that 
> might've triggered it.
> 
> Ful dmesg & .config: http://nerdbynature.de/bits/3.3.0-rc4/ipv4/
> 
> Note: the machine's internal battery seems to be bad, that's why the 
> timestamps during bootup are b0rked in those logfiles.
> 
> Please Cc me on replies as I'm not subscribed to netdev.
> 
> Thanks,
> Christian.
> -- 
> BOFH excuse #444:
> 
> overflow error in /dev/null
> 

-- 
BOFH excuse #29:

It works the way the Wang did, what's the problem
