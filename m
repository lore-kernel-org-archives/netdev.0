From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: [BUG] New Kernel Bugs
Date: Mon, 12 Nov 2007 22:42:32 -0800
Message-ID: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-input@
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the listing of the open bugs that are relatively new, around
2.6.22 and up. They are vaguely classified by specific area.
(not a full list, there are more :)

The good part is that reporters of the bugs below are still around and
haven't dissipated, or disposed of their hardware, so it is a good
time to get the bugs.
Those bugzillas that have been started as regressions on Rafael's list
are not mentioned here so far, since they are being tracked as new
regressions already.

It would be appreciated if the corresponding maintenance team could take a
look, close off any which are fixed and see if they can fix any which aren't.

NOTE: when replying to this email, please add the bug number to the Subject in
the form [Bug 1234] so that bugzilla will capture the discussion.
Thanks.

ACPI====================================================================

System does not load without acpi=off ide=nodma noapic
http://bugzilla.kernel.org/show_bug.cgi?id=9358
Kernel: 2.6.23.1

ACPI Error attaching device data
http://bugzilla.kernel.org/show_bug.cgi?id=9354
Kernel: 2.6.24-rc2

/proc/acpi/battery displays Incorrect voltages
http://bugzilla.kernel.org/show_bug.cgi?id=9341
Kernel: 2.6.23.1

PATA scan: ACPI Exception AE_AML_PACKAGE_LIMIT... is beyond end of object
http://bugzilla.kernel.org/show_bug.cgi?id=9320
Kernel: 2.6.24-rc2
(Tejun: calling _GTF without calling _STM first.  _GTM doesn't have any
prerequisite (it can't).  Can someone familiar with ACPI tell me why the method
is failing?  At any rate, libata should work fine regardless of ACPI failures.
Maybe it's time to start blacklist to skip ATA-ACPI for some boards to avoid
those annoying messages during boot)

ACPI Battery Info in /sys but not /proc/acpi
http://bugzilla.kernel.org/show_bug.cgi?id=9183
Kernel: 2.6.23-rc8-mm2

When using ACPI on a Compaq Presario V6221EU the laptop goes into
deadlock after a random amount of time
http://bugzilla.kernel.org/show_bug.cgi?id=9118
Kernel: 2.6.23-rc6

ACPI video driver should validate brightness level before setting it via _BCM
http://bugzilla.kernel.org/show_bug.cgi?id=9277
Kernel: 2.6.23

VIDEO/DVB

dvb driver reboot system
http://bugzilla.kernel.org/show_bug.cgi?id=9357
Kernel: 2.6.21.5


PLATFORM===============================================================

xipImage is built so that uBoot cant run it (ARM)
http://bugzilla.kernel.org/show_bug.cgi?id=9356
Kernel: 2.6.21

Samsung R20 - ACPI: PCI Root Bridge [PCI0] (0000:00)	
http://bugzilla.kernel.org/show_bug.cgi?id=9339
Kernel: 2.6.24
(boot is very long
..MP-BIOS bug: 8254 timer not connected to IO-APIC
then the boot stop at :
ACPI: PCI Root Bridge [PCI0] (0000:00)
(during 3 minutes, and boot continue)

system_64.h: switch_to inline asm should be more robbust wrt optimizations
http://bugzilla.kernel.org/show_bug.cgi?id=9302
Kernel: 2.6.24-rc1

with CONFIG_NO_HZ and/or CONFIG_HPET_TIMER set kernel 2.6.23 doesn't
boot (ARM, Timer)
http://bugzilla.kernel.org/show_bug.cgi?id=9229
Kernel: 2.6.23

NETWORKING===========================================================

RTNLGRP_ND_USEROPT does not report ifindex (IPv6)
http://bugzilla.kernel.org/show_bug.cgi?id=9349
Kernel: 2.6.24+

a kernel error happend in the func: __skb_dequeue when using in
pfifo_fast_dequeue
http://bugzilla.kernel.org/show_bug.cgi?id=9342
Kernel: 2.6.11.1 - reporter asked to try recent kernel

e100 does not work after boot
http://bugzilla.kernel.org/show_bug.cgi?id=9336
Kernel: 2.6.23.1

2.6.23.1-smp kernel panic (network-related)
http://bugzilla.kernel.org/show_bug.cgi?id=9318
Kernel: 2.6.23.1
Infiniband panic

sundance -> 4port D-Link System Inc DFE-580TX -> Log errors
http://bugzilla.kernel.org/show_bug.cgi?id=9311
Kernel: 2.6.22.9

via-rhine driver stalls with: PHY status 786d, resetting...
http://bugzilla.kernel.org/show_bug.cgi?id=9300
Kernel: 2.6.23+


Weird network problems with 2.6.23-rc2
http://bugzilla.kernel.org/show_bug.cgi?id=9080
http://lkml.org/lkml/2007/8/11/40 - description

rt2500pci: low TCP throughput (wireless)
http://bugzilla.kernel.org/show_bug.cgi?id=9273
Kernel: 2.6.24-rc1
This is a regression

Unable to build wifi network between zd1201 and b43
http://bugzilla.kernel.org/show_bug.cgi?id=9237
Kernel: 2.6.24-rc1

Crash after module unload in b43 (wireless)
http://bugzilla.kernel.org/show_bug.cgi?id=9233
Kernel: 2.6.24-rc1

(net typhoon) "no descs for cmd, had (needed) 0 (1) cmd, 31 (7) resp"
http://bugzilla.kernel.org/show_bug.cgi?id=9225
Kernel: 2.6.23.1


IDE/SATA=========================================================

pata_pdc202xx_old excessive ATA bus errors
http://bugzilla.kernel.org/show_bug.cgi?id=9337
2.6.24-rc2

Drive seagate ST380011AS needs to be blacklisted
http://bugzilla.kernel.org/show_bug.cgi?id=9309
Kernel: 2.6.22.X

DVD-RAM umount and disk free bug
http://bugzilla.kernel.org/show_bug.cgi?id=9265
Kernel: 2.6.15  (asked to try current kernel)

FILE SYSTEMS=======================================================

ext4: delalloc space accounting problem drops data
http://bugzilla.kernel.org/show_bug.cgi?id=9329
Kernel: 2.6.24-rc1

POSIX Access Control Lists cause bogus file system check errors
http://bugzilla.kernel.org/show_bug.cgi?id=9241
Kernel: 2.6.23.1

MEMORY MANAGEMENT================================================

My system hangs when it has no more free memory to allocate via malloc()
http://bugzilla.kernel.org/show_bug.cgi?id=9316
Kernel: 2.6.23
User program, "My system hangs when it has no more free memory to
allocate via malloc()"

BUG: unable to handle kernel paging request at virtual address
26121228/kswapd0[231] exited with preempt_count 1
http://bugzilla.kernel.org/show_bug.cgi?id=9305
EIP is at free_block+0x6d/0xe4
Kernel: 2.6.22.6

POWER MANAGEMENT==================================================

IBM X41 looses time after Suspend2Disk
http://bugzilla.kernel.org/show_bug.cgi?id=9314
Kernel: 2.6.23

Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
http://bugzilla.kernel.org/show_bug.cgi?id=9275
Kernel: 2.6.23
This is HP notebook nc6320 T2400 945GM


VIDEO DRIVERS========================================================

No text consoles with FRAMEBUFFER_CONSOLE_DETECT_PRIMARY
http://bugzilla.kernel.org/show_bug.cgi?id=9310
Kernel: 2.6.24-rc1
This is a regression


PARALLEL PORT========================================================

LPC IT8705 POST port making noise on parallel port
http://bugzilla.kernel.org/show_bug.cgi?id=9306
Kernel: 2.6.16+


I/O STORAGE===========================================================

kernel bug from pktcdvd
http://bugzilla.kernel.org/show_bug.cgi?id=9294
Kernel: 2.6.23

After pci-e video card was installed, pci add-on usb card & firewire card fail
http://bugzilla.kernel.org/show_bug.cgi?id=9223
Kernel: 2.6.20 (testing of latest kernel requested)

SCSI==================================================================

qla2xxx: driver initialization does not complete when booting with
Port connected
http://bugzilla.kernel.org/show_bug.cgi?id=9267
Kernel: 2.6.23.1

SOUND ALSA============================================================

Unable to load snd-hda-intel module: Unknown symbol in module, or
unknown parameter
http://bugzilla.kernel.org/show_bug.cgi?id=9242
Kernel: 2.6.24-rc1

usbaudio microphone: regular sound distortion on several Logitech Webcams
http://bugzilla.kernel.org/show_bug.cgi?id=9230
Kernel: 2.6.22.9

HID====================================================================

Kernel NULL pointer dereference at :usbhid:hiddev_ioctl+0x2f/0xabc
http://bugzilla.kernel.org/show_bug.cgi?id=9216
Kernel: 2.6.23.1
Looks like this is a regression
