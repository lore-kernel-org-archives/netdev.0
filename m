From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.8 + sarge = pb
Date: Mon, 16 Aug 2004 07:40:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816144008.GZ11200@holomorphy.com>
References: <20040816094446.50165.qmail@web41905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: remy harel <remy_harel@yahoo.fr>
Content-Disposition: inline
In-Reply-To: <20040816094446.50165.qmail@web41905.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A user got an oops in fib_sync_down(). I tried to clean up the syslog
stuff here so hopefully it's not tremendously confusing.


On Mon, Aug 16, 2004 at 11:44:46AM +0200, remy harel wrote:
>  I have a problem, with the last kernel, a 2.6.8-1 on
> a sarge. I've compiled it well, without initrd ( it
> refuses to compile with ) on this server :
>  HP netserver LH II ( bipro PII 266 / 512Mo ECC / 2 x
> SCSI UW +  Raid Netraid SCSI UW 3 canaux ( 8mo ECC ) /
> 6xSCSI 9.1 Go Hot Swap raid 5 / rack 2Go IDE ( backup
> ) / 2*400W 2 / 4 x LAN /  APC Smart UPS 1000 / Debian
> testing kernel 2.6.8.1
> It runs, but not stable, I've got some freeze, there
> is a trace of my log, just before the last freeze.
> Thanks to help me,
> best regards,
> Unable to handle kernel paging request at virtual address 042454df
> printing eip: c02573d5
> *pde 00000000
> Oops: 0000 [#1] PREEMPT SMP
> Modules linked in: tun sch_ingress cls_u32 sch_sfq sch_htb
> nfsd exportfs lockd sunrpc ipt_MASQUERADE ipt_REDIRECT
> ipt_state iptable_filter ppp_deflate zlib_deflate
> bsd_comp capability commoncap af_packet ppp_async
> crc_ccitt ipv6 ppp_generic slhc bridge evdev e100 mii
> ide_disk ide_generic ide_core ne 8390 crc32 ip_nat_ftp
> iptable_nat ip_tables ip_conntrack_ftp ip_conntrack
> unix
> CPU:    1
> EIP:  0060:[fib_sync_down+92/289]    Not tainted
> EFLAGS: 00010286 (2.6.8.1.15082004)
> EIP is at fib_sync_down+0x5c/0x121
> eax: de6b5400   ebx: 0424548b   ecx: c14106e0   edx: 00012b84
> esi: c02232e7   edi: 0000003e   ebp: 00000098   esp: d023decc
> ds: 007b   es: 007b ss: 0068
> Process openvpn
> (pid: 2640, threadinfo=d023c000 task=df6e72b0)
> Stack: 000000ff 00000000 de6b5400 de6b5400 00000002 d7d63e3c c0256017
> 00000000 de6b5400 00000000 c02fefc8 c02560f3 de6b5400 00000000 c02fefc8
> de6b5400 c0122f7c c02fefc8 00000002 de6b5400 de6b5400 de6b5400 dffc39e0
> c02185d8
> Call Trace:
> [fib_disable_ip+17/47] fib_disable_ip+0x11/0x2f
> [fib_netdev_event+96/113] fib_netdev_event+0x60/0x71
> [notifier_call_chain+28/56] notifier_call_chain+0x1c/0x38
> [dev_close+116/123] dev_close+0x74/0x7b
> [unregister_netdevice+150/592] unregister_netdevice+0x96/0x250
> [pg0+542619954/1069940736] tun_chr_close+0x61/0x6c [tun]
> [__fput+65/259] __fput+0x41/0x103
> [filp_close+89/98] filp_close+0x59/0x62
> [sys_close+113/153] sys_close+0x71/0x99
> [syscall_call+7/11] syscall_call+0x7/0xb
> Aug 16 10:16:47 localhost kernel: Code: 8b 43 54 85 c0
> 0f 84 a5 00 00 00 31 ff 31 ed 39 c7 8d 73 5c

I could use help here. I'm not very knowledgable as far as net/ goes.


-- wli
