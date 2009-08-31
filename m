From: Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
Subject: Re: Latest PreemptRT patch error on imx35
Date: Mon, 31 Aug 2009 17:29:32 +0200
Message-ID: <200908311729.33114.tim01@vlsi.informatik.tu-darmstadt.de>
References: <200908311143.08952.tim01@vlsi.informatik.tu-darmstadt.de> <20090831132200.GA21836@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rt-users <linux-rt-users@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>, netdev@vger.kernel.org
To: Uwe =?iso-8859-1?q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090831132200.GA21836@pengutronix.de>
Content-Disposition: inline
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I just chrosschecked and build a kernel without a preempt RT patch. Two=
 conclusions:=20

* A 2.6.31-rc8-rt9 patched kernel is booting under preempt-rt with FEC-=
Etheret failing as reported or not at all with the configuration: preem=
pt or no-preemption (server).=20

* A 2.6.31-rc8 boots on the imx35 board.

Below a output dump of a failed boot of no-preemption 2.6.31-rc8-rt9 ke=
rnel

Best regards
Tim


Uncompressing Linux....................................................=
=2E................................................. done, booting the =
kernel.
Linux version 2.6.31-rc8-rt9 (sander@dose) (gcc version 4.3.2 (OSELAS.T=
oolchain-1.99.3) ) #4 Mon Aug 31 13:33:49 CEST 2009
CPU: ARMv6-compatible processor [4117b363] revision 3 (ARMv6TEJ), cr=3D=
00c5387f
CPU: VIPT nonaliasing data cache, VIPT nonaliasing instruction cache
Machine: Phytec Phycore pcm043
Memory policy: ECC disabled, Data cache writeback
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32=
512
Kernel command line: jtag=3Don console=3Dttymxc0,115200 video=3Dmx3fb:T=
X090 ip=3D172.19.169.71:172.19.169.15::255.255.0.0::: root=3D/dev/mtdbl=
ock3 rootfstype=3Djffs2 mtdparts=3Dphysmap-flash.0:256k(uboot)ro,128k(u=
bootenv),2048k(kernel),-(root);mxc_nand:
PID hash table entries: 512 (order: 9, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 128MB =3D 128MB total
Memory: 126492KB available (2824K code, 265K data, 96K init, 0K highmem=
)
Hierarchical RCU implementation.
NR_IRQS:180
MXC GPIO hardware
MXC IRQ initialized
Console: colour dummy device 80x30
Calibrating delay loop... 398.95 BogoMIPS (lpj=3D1994752)
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok
NET: Registered protocol family 16
L2X0 cache controller enabled
bio: create slab <bio-0> at 0
NET: Registered protocol family 2
IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
TCP established hash table entries: 4096 (order: 3, 32768 bytes)
TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
TCP: Hash tables configured (established 4096 bind 4096)
TCP reno registered
NET: Registered protocol family 1
JFFS2 version 2.2. (NAND) =A9 2001-2006 Red Hat, Inc.
msgmni has been set to 247
alg: No test for stdrng (krng)
io scheduler noop registered (default)
Serial: IMX driver
imx-uart.0: ttymxc0 at MMIO 0x43f90000 (irq =3D 45) is a IMX
console [ttymxc0] enabled
imx-uart.1: ttymxc1 at MMIO 0x43f94000 (irq =3D 32) is a IMX
=46EC Ethernet Driver
fec: PHY @ 0x0, ID 0x00221512 -- unknown PHY!
physmap platform flash device: 02000000 at a0000000
physmap-flash.0: Found 1 x16 devices at 0x0 in 16-bit bank
 Intel/Sharp Extended Query Table at 0x010A
 Intel/Sharp Extended Query Table at 0x010A
 Intel/Sharp Extended Query Table at 0x010A
 Intel/Sharp Extended Query Table at 0x010A
 Intel/Sharp Extended Query Table at 0x010A
Using buffer write method
Using auto-unlock on power-up/resume
cfi_cmdset_0001: Erase suspend on write enabled
mtd: partition size too small (0)
4 cmdlinepart partitions found on MTD device physmap-flash.0
Creating 4 MTD partitions on "physmap-flash.0":
0x000000000000-0x000000040000 : "uboot"
0x000000040000-0x000000060000 : "ubootenv"
0x000000060000-0x000000260000 : "kernel"
0x000000260000-0x000002000000 : "root"
mice: PS/2 mouse device common for all mice
Driver for 1-wire Dallas network protocol.
cpuidle: using governor ladder
TCP cubic registered
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
VFP support v0.3: implementor 41 architecture 1 part 20 variant b rev 3
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
IP-Config: Complete:
     device=3Deth0, addr=3D172.19.169.71, mask=3D255.255.0.0, gw=3D255.=
255.255.255,
     host=3D172.19.169.71, domain=3D, nis-domain=3D(none),
     bootserver=3D172.19.169.15, rootserver=3D172.19.169.15, rootpath=3D
VFS: Mounted root (jffs2 filesystem) on device 31:3.
=46reeing init memory: 96K
Unable to handle kernel paging request at virtual address de609800
pgd =3D c0004000
[de609800] *pgd=3D00000000
Internal error: Oops: 805 [#1]
Modules linked in:
CPU: 0    Not tainted  (2.6.31-rc8-rt9 #4)
PC is at __lru_cache_add+0x5c/0x84
LR is at add_to_page_cache_lru+0xa4/0xa8
pc : [<c006ace0>]    lr : [<c0062430>]    psr: a0000013
sp : c7819d04  ip : 00000190  fp : c7407648
r10: c740764c  r9 : 0000005b  r8 : 00100100
r7 : 00200200  r6 : 00000000  r5 : 00000002  r4 : c0305bc8
r3 : c78c0ea9  r2 : c78c0eaa  r1 : c0305d58  r0 : c0342760
=46lags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 00c5387d  Table: 80004008  DAC: 00000017
Process swapper (pid: 1, stack limit =3D 0xc7818268)
Stack: (0xc7819d04 to 0xc781a000)
9d00:          c0342760 00000000 00000004 0000005b c0342760 00000000 c0=
069ecc
9d20: c788c380 c7819d38 c74059b8 00000001 c787d9c0 00000004 c0344b78 c0=
33c3f8
9d40: c7407700 00000003 00000000 00000000 00000000 c7407648 c787d9c0 c7=
87d9c0
9d60: 00000000 c0069f4c 00000003 c787d9c0 00000000 c006a328 00000000 00=
000001
9d80: 00000001 c0062dfc 00000001 c042f580 c0061930 c7819df4 c7819e88 c7=
4075b0
9da0: c787da00 00000001 ffffffff 00000fff 00000000 00000000 00000000 00=
000000
9dc0: 00000000 c7819ec8 c787d9c0 00000000 c7819df4 c0063bac c031c814 c0=
31c5b0
9de0: 00000000 000000d0 c7819e88 00000001 c031cb60 00000000 00000080 c7=
8821a0
9e00: 00000000 00000080 00000000 00000000 00000000 c7815cc0 c7819e38 c7=
87d9c0
9e20: fffffdee c7819ec8 c7819f18 c0088754 00000000 00000000 00000004 00=
000000
9e40: 00000000 00000001 ffffffff c787d9c0 00000000 00000000 00000000 00=
000000
9e60: c7815cc0 00000000 00000000 00000000 00000000 c7815cc0 c0049aac c7=
819e7c
9e80: c7819e7c c008498c 00000000 00000000 c031c5b0 c79abde0 c78028f0 00=
0f4240
9ea0: 00000080 c7815cc0 c02ff9d0 c7815cc0 00000000 00000000 ffffffff 00=
000000
9ec0: c7824000 c004e0f8 c78821a0 00000080 00000017 c787d9c0 c78821a0 c7=
819f18
9ee0: c78821a0 00000080 c7819f78 c02fb8c4 00000000 c00893c8 fffffeff ff=
ffffff
9f00: c7819f18 00000000 000089ed c78821a0 c02fb838 c008dad8 00000000 00=
000000
9f20: c7819f78 c78821a0 c74075b0 c008dbfc c78821a0 00000080 00000004 c0=
2fb848
9f40: c7818000 c008e36c 00000000 00000000 c7819f60 c02a2740 c02fb8c4 c0=
2fb838
9f60: 00000000 00000000 00000000 00000000 00000000 c0023a70 00000000 00=
000000
9f80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00=
000000
9fa0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00=
000000
9fc0: 00000000 c02fb8c4 c031cbd4 00000000 00000000 c0020514 c001bfa8 c0=
01bfa8
9fe0: c001bfa8 c0008464 00000000 00000000 00000000 c002179c fffbfef1 dd=
cfe9fd
[<c006ace0>] (__lru_cache_add+0x5c/0x84) from [<0000005b>] (0x5b)
Code: e794200c e2823001 e2822002 e3530008 (e7810102)
---[ end trace bb332da858e3d4c4 ]---
Kernel panic - not syncing: Attempted to kill init!
[<c0025618>] (unwind_backtrace+0x0/0xe4) from [<c0246bcc>] (panic+0x3c/=
0x120)
[<c0246bcc>] (panic+0x3c/0x120) from [<c003913c>] (forget_original_pare=
nt+0x240/0x278)
[<c003913c>] (forget_original_parent+0x240/0x278) from [<c0039188>] (ex=
it_notify+0x14/0x154)
[<c0039188>] (exit_notify+0x14/0x154) from [<c00393c4>] (do_exit+0xfc/0=
x294)
[<c00393c4>] (do_exit+0xfc/0x294) from [<c0024488>] (die+0xac/0xbc)
[<c0024488>] (die+0xac/0xbc) from [<c0026670>] (__do_kernel_fault+0x70/=
0x80)
[<c0026670>] (__do_kernel_fault+0x70/0x80) from [<c00268b4>] (do_transl=
ation_fault+0x6c/0x80)
[<c00268b4>] (do_translation_fault+0x6c/0x80) from [<c0020254>] (do_Dat=
aAbort+0x34/0x98)
[<c0020254>] (do_DataAbort+0x34/0x98) from [<c0020a4c>] (__dabt_svc+0x4=
c/0x60)
Exception stack(0xc7819cb8 to 0xc7819d00)
9ca0:                                                       c0342760 c0=
305d58
9cc0: c78c0eaa c78c0ea9 c0305bc8 00000002 00000000 00200200 00100100 00=
00005b
9ce0: c740764c c7407648 00000190 c7819d04 c0062430 c006ace0 a0000013 ff=
ffffff
[<c0020a4c>] (__dabt_svc+0x4c/0x60) from [<c006ace0>] (__lru_cache_add+=
0x5c/0x84)
[<c006ace0>] (__lru_cache_add+0x5c/0x84) from [<0000005b>] (0x5b)

__lru_cache_add+0x5c/0x84
LR is at add_to_page_cache_lru+0xa4/0xa8
pc : [<c006ace0>]    lr : [<c0062430>]    psr: a0000013
sp : c7819d04  ip : 00000190  fp : c7407648
r10: c740764c  r9 : 0000005b  r8 : 00100100
r7 : 00200200  r6 : 00000000  r5 : 00000002  r4 : c0305bc8
r3 : c78c0ea9  r2 : c78c0eaa  r1 : c0305d58  r0 : c0342760
=46lags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 00c5387d  Table: 80004008  DAC: 00000017
Process swapper (pid: 1, stack limit =3D 0xc7818268)
Stack: (0xc7819d04 to 0xc781a000)
9d00:          c0342760 00000000 00000004 0000005b c0342760 00000000 c0=
069ecc
9d20: c788c380 c7819d38 c74059b8 00000001 c787d9c0 00000004 c0344b78 c0=
33c3f8
9d40: c7407700 00000003 00000000 00000000 00000000 c7407648 c787d9c0 c7=
87d9c0
9d60: 00000000 c0069f4c 00000003 c787d9c0 00000000 c006a328 00000000 00=
000001
9d80: 00000001 c0062dfc 00000001 c042f580 c0061930 c7819df4 c7819e88 c7=
4075b0
9da0: c787da00 00000001 ffffffff 00000fff 00000000 00000000 00000000 00=
000000
9dc0: 00000000 c7819ec8 c787d9c0 00000000 c7819df4 c0063bac c031c814 c0=
31c5b0
9de0: 00000000 000000d0 c7819e88 00000001 c031cb60 00000000 00000080 c7=
8821a0
9e00: 00000000 00000080 00000000 00000000 00000000 c7815cc0 c7819e38 c7=
87d9c0
9e20: fffffdee c7819ec8 c7819f18 c0088754 00000000 00000000 00000004 00=
000000
9e40: 00000000 00000001 ffffffff c787d9c0 00000000 00000000 00000000 00=
000000
9e60: c7815cc0 00000000 00000000 00000000 00000000 c7815cc0 c0049aac c7=
819e7c
9e80: c7819e7c c008498c 00000000 00000000 c031c5b0 c79abde0 c78028f0 00=
0f4240
9ea0: 00000080 c7815cc0 c02ff9d0 c7815cc0 00000000 00000000 ffffffff 00=
000000
9ec0: c7824000 c004e0f8 c78821a0 00000080 00000017 c787d9c0 c78821a0 c7=
819f18
9ee0: c78821a0 00000080 c7819f78 c02fb8c4 00000000 c00893c8 fffffeff ff=
ffffff
9f00: c7819f18 00000000 000089ed c78821a0 c02fb838 c008dad8 00000000 00=
000000
9f20: c7819f78 c78821a0 c74075b0 c008dbfc c78821a0 00000080 00000004 c0=
2fb848
9f40: c7818000 c008e36c 00000000 00000000 c7819f60 c02a2740 c02fb8c4 c0=
2fb838
9f60: 00000000 00000000 00000000 00000000 00000000 c0023a70 00000000 00=
000000
9f80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00=
000000
9fa0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00=
000000
9fc0: 00000000 c02fb8c4 c031cbd4 00000000 00000000 c0020514 c001bfa8 c0=
01bfa8
9fe0: c001bfa8 c0008464 00000000 00000000 00000000 c002179c fffbfef1 dd=
cfe9fd
[<c006ace0>] (__lru_cache_add+0x5c/0x84) from [<0000005b>] (0x5b)
Code: e794200c e2823001 e2822002 e3530008 (e7810102)
---[ end trace bb332da858e3d4c4 ]---
Kernel panic - not syncing: Attempted to kill init!
[<c0025618>] (unwind_backtrace+0x0/0xe4) from [<c0246bcc>] (panic+0x3c/=
0x120)
[<c0246bcc>] (panic+0x3c/0x120) from [<c003913c>] (forget_original_pare=
nt+0x240/0x278)
[<c003913c>] (forget_original_parent+0x240/0x278) from [<c0039188>] (ex=
it_notify+0x14/0x154)
[<c0039188>] (exit_notify+0x14/0x154) from [<c00393c4>] (do_exit+0xfc/0=
x294)
[<c00393c4>] (do_exit+0xfc/0x294) from [<c0024488>] (die+0xac/0xbc)
[<c0024488>] (die+0xac/0xbc) from [<c0026670>] (__do_kernel_fault+0x70/=
0x80)
[<c0026670>] (__do_kernel_fault+0x70/0x80) from [<c00268b4>] (do_transl=
ation_fault+0x6c/0x80)
[<c00268b4>] (do_translation_fault+0x6c/0x80) from [<c0020254>] (do_Dat=
aAbort+0x34/0x98)
[<c0020254>] (do_DataAbort+0x34/0x98) from [<c0020a4c>] (__dabt_svc+0x4=
c/0x60)
Exception stack(0xc7819cb8 to 0xc7819d00)
9ca0:                                                       c0342760 c0=
305d58
9cc0: c78c0eaa c78c0ea9 c0305bc8 00000002 00000000 00200200 00100100 00=
00005b
9ce0: c740764c c7407648 00000190 c7819d04 c0062430 c006ace0 a0000013 ff=
ffffff
[<c0020a4c>] (__dabt_svc+0x4c/0x60) from [<c006ace0>] (__lru_cache_add+=
0x5c/0x84)
[<c006ace0>] (__lru_cache_add+0x5c/0x84) from [<0000005b>] (0x5b)
--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
