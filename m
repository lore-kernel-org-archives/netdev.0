From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 03:15:53 -0800
Message-ID: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-input@atrey.karlin.mff.cuni.cz,
        bugme-daemon@bugzilla.kernel.org
To: "Natalie Protasevich" <protasnb@gmail.com>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Mon, 12 Nov 2007 22:42:32 -0800 "Natalie Protasevich" <protasnb@gmail.com> wrote:

> This is the listing of the open bugs that are relatively new, around
> 2.6.22 and up. They are vaguely classified by specific area.
> (not a full list, there are more :)
> 
> The good part is that reporters of the bugs below are still around and
> haven't dissipated, or disposed of their hardware, so it is a good
> time to get the bugs.
> Those bugzillas that have been started as regressions on Rafael's list
> are not mentioned here so far, since they are being tracked as new
> regressions already.

Thanks.

> It would be appreciated if the corresponding maintenance team could take a
> look, close off any which are fixed and see if they can fix any which aren't.
> 
> NOTE: when replying to this email, please add the bug number to the Subject in
> the form [Bug 1234] so that bugzilla will capture the discussion.
> Thanks.

You're optimistic.



> ACPI====================================================================
> 
> System does not load without acpi=off ide=nodma noapic
> http://bugzilla.kernel.org/show_bug.cgi?id=9358
> Kernel: 2.6.23.1

One response from a developer

> ACPI Error attaching device data
> http://bugzilla.kernel.org/show_bug.cgi?id=9354
> Kernel: 2.6.24-rc2

Zero responses from developers

> /proc/acpi/battery displays Incorrect voltages
> http://bugzilla.kernel.org/show_bug.cgi?id=9341
> Kernel: 2.6.23.1

Zero responses from developers

> PATA scan: ACPI Exception AE_AML_PACKAGE_LIMIT... is beyond end of object
> http://bugzilla.kernel.org/show_bug.cgi?id=9320
> Kernel: 2.6.24-rc2
> (Tejun: calling _GTF without calling _STM first.  _GTM doesn't have any
> prerequisite (it can't).  Can someone familiar with ACPI tell me why the method
> is failing?  At any rate, libata should work fine regardless of ACPI failures.
> Maybe it's time to start blacklist to skip ATA-ACPI for some boards to avoid
> those annoying messages during boot)

Tejun doing stuff

> ACPI Battery Info in /sys but not /proc/acpi
> http://bugzilla.kernel.org/show_bug.cgi?id=9183
> Kernel: 2.6.23-rc8-mm2

Marked as a duplicate of an already-resolved bug.

> 
> When using ACPI on a Compaq Presario V6221EU the laptop goes into
> deadlock after a random amount of time
> http://bugzilla.kernel.org/show_bug.cgi?id=9118
> Kernel: 2.6.23-rc6

Someone called Jike Song is trying to help out.  Regular developers awol.

> 
> ACPI video driver should validate brightness level before setting it via _BCM
> http://bugzilla.kernel.org/show_bug.cgi?id=9277
> Kernel: 2.6.23

Zero responses from developers

> VIDEO/DVB
> 
> dvb driver reboot system
> http://bugzilla.kernel.org/show_bug.cgi?id=9357
> Kernel: 2.6.21.5

Mauro thinks it might be bad hardware

> 
> PLATFORM===============================================================
> 
> xipImage is built so that uBoot cant run it (ARM)
> http://bugzilla.kernel.org/show_bug.cgi?id=9356
> Kernel: 2.6.21

Zero responses from developers

> 
> Samsung R20 - ACPI: PCI Root Bridge [PCI0] (0000:00)	
> http://bugzilla.kernel.org/show_bug.cgi?id=9339
> Kernel: 2.6.24
> (boot is very long
> ..MP-BIOS bug: 8254 timer not connected to IO-APIC
> then the boot stop at :
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> (during 3 minutes, and boot continue)

No response from developers

> system_64.h: switch_to inline asm should be more robbust wrt optimizations
> http://bugzilla.kernel.org/show_bug.cgi?id=9302
> Kernel: 2.6.24-rc1

Not really a bug.

> with CONFIG_NO_HZ and/or CONFIG_HPET_TIMER set kernel 2.6.23 doesn't
> boot (ARM, Timer)
> http://bugzilla.kernel.org/show_bug.cgi?id=9229
> Kernel: 2.6.23

No response from developers

> NETWORKING===========================================================
> 
> RTNLGRP_ND_USEROPT does not report ifindex (IPv6)
> http://bugzilla.kernel.org/show_bug.cgi?id=9349
> Kernel: 2.6.24+

No response from developers

> a kernel error happend in the func: __skb_dequeue when using in
> pfifo_fast_dequeue
> http://bugzilla.kernel.org/show_bug.cgi?id=9342
> Kernel: 2.6.11.1 - reporter asked to try recent kernel

No response from developers

> e100 does not work after boot
> http://bugzilla.kernel.org/show_bug.cgi?id=9336
> Kernel: 2.6.23.1

No response from developers

> 2.6.23.1-smp kernel panic (network-related)
> http://bugzilla.kernel.org/show_bug.cgi?id=9318
> Kernel: 2.6.23.1
> Infiniband panic

No response from developers

> sundance -> 4port D-Link System Inc DFE-580TX -> Log errors
> http://bugzilla.kernel.org/show_bug.cgi?id=9311
> Kernel: 2.6.22.9

No response from developers

> via-rhine driver stalls with: PHY status 786d, resetting...
> http://bugzilla.kernel.org/show_bug.cgi?id=9300
> Kernel: 2.6.23+

No response from developers

> 
> Weird network problems with 2.6.23-rc2
> http://bugzilla.kernel.org/show_bug.cgi?id=9080
> http://lkml.org/lkml/2007/8/11/40 - description

No response from developers

> rt2500pci: low TCP throughput (wireless)
> http://bugzilla.kernel.org/show_bug.cgi?id=9273
> Kernel: 2.6.24-rc1
> This is a regression

No response from developers

> Unable to build wifi network between zd1201 and b43
> http://bugzilla.kernel.org/show_bug.cgi?id=9237
> Kernel: 2.6.24-rc1

No response from developers

> Crash after module unload in b43 (wireless)
> http://bugzilla.kernel.org/show_bug.cgi?id=9233
> Kernel: 2.6.24-rc1

No response from developers

> (net typhoon) "no descs for cmd, had (needed) 0 (1) cmd, 31 (7) resp"
> http://bugzilla.kernel.org/show_bug.cgi?id=9225
> Kernel: 2.6.23.1

No response from developers

> 
> IDE/SATA=========================================================
> 
> pata_pdc202xx_old excessive ATA bus errors
> http://bugzilla.kernel.org/show_bug.cgi?id=9337
> 2.6.24-rc2

No response from developers

> Drive seagate ST380011AS needs to be blacklisted
> http://bugzilla.kernel.org/show_bug.cgi?id=9309
> Kernel: 2.6.22.X

Jeff and Tehun did some stuff.

> DVD-RAM umount and disk free bug
> http://bugzilla.kernel.org/show_bug.cgi?id=9265
> Kernel: 2.6.15  (asked to try current kernel)

No response from developers

> FILE SYSTEMS=======================================================
> 
> ext4: delalloc space accounting problem drops data
> http://bugzilla.kernel.org/show_bug.cgi?id=9329
> Kernel: 2.6.24-rc1

No response from developers

> POSIX Access Control Lists cause bogus file system check errors
> http://bugzilla.kernel.org/show_bug.cgi?id=9241
> Kernel: 2.6.23.1

Andreas did some work, seemed to lose interest.

> MEMORY MANAGEMENT================================================
> 
> My system hangs when it has no more free memory to allocate via malloc()
> http://bugzilla.kernel.org/show_bug.cgi?id=9316
> Kernel: 2.6.23
> User program, "My system hangs when it has no more free memory to
> allocate via malloc()"

Rafael poked Thomas a week ago, to no effect. Thomas has been travelling.

> BUG: unable to handle kernel paging request at virtual address
> 26121228/kswapd0[231] exited with preempt_count 1
> http://bugzilla.kernel.org/show_bug.cgi?id=9305
> EIP is at free_block+0x6d/0xe4
> Kernel: 2.6.22.6

No response from developers

> POWER MANAGEMENT==================================================
> 
> IBM X41 looses time after Suspend2Disk
> http://bugzilla.kernel.org/show_bug.cgi?id=9314
> Kernel: 2.6.23

Rafael poked Thomas a week ago, to no effect.  Thomas has been travelling.

> Suspend to RAM resume hangs on a tickless (NO_HZ) kernel
> http://bugzilla.kernel.org/show_bug.cgi?id=9275
> Kernel: 2.6.23
> This is HP notebook nc6320 T2400 945GM

No response from developers

> 
> VIDEO DRIVERS========================================================
> 
> No text consoles with FRAMEBUFFER_CONSOLE_DETECT_PRIMARY
> http://bugzilla.kernel.org/show_bug.cgi?id=9310
> Kernel: 2.6.24-rc1
> This is a regression

No response from developers

> 
> PARALLEL PORT========================================================
> 
> LPC IT8705 POST port making noise on parallel port
> http://bugzilla.kernel.org/show_bug.cgi?id=9306
> Kernel: 2.6.16+
> 

No response from developers

> I/O STORAGE===========================================================
> 
> kernel bug from pktcdvd
> http://bugzilla.kernel.org/show_bug.cgi?id=9294
> Kernel: 2.6.23

I think we might have fixed this.

> After pci-e video card was installed, pci add-on usb card & firewire card fail
> http://bugzilla.kernel.org/show_bug.cgi?id=9223
> Kernel: 2.6.20 (testing of latest kernel requested)

No response from developers

> SCSI==================================================================
> 
> qla2xxx: driver initialization does not complete when booting with
> Port connected
> http://bugzilla.kernel.org/show_bug.cgi?id=9267
> Kernel: 2.6.23.1

No response from developers

> SOUND ALSA============================================================
> 
> Unable to load snd-hda-intel module: Unknown symbol in module, or
> unknown parameter
> http://bugzilla.kernel.org/show_bug.cgi?id=9242
> Kernel: 2.6.24-rc1

Takashi has responded

> usbaudio microphone: regular sound distortion on several Logitech Webcams
> http://bugzilla.kernel.org/show_bug.cgi?id=9230
> Kernel: 2.6.22.9

Clemens responded

> HID====================================================================
> 
> Kernel NULL pointer dereference at :usbhid:hiddev_ioctl+0x2f/0xabc
> http://bugzilla.kernel.org/show_bug.cgi?id=9216
> Kernel: 2.6.23.1
> Looks like this is a regression

No response from developers


So I count around seven reports which people are doing something with and
twenty seven which have been just ignored.

Three of these reports have been identified as regressions.  All three
of those remain unresponded to.
