From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: CIFS mount: 3.2.0-rc3 suspend crash
Date: Fri, 02 Dec 2011 18:19:04 +0530
Message-ID: <4ED8C940.20509@linux.vnet.ibm.com>
References: <4ED56C12.1040708@gmail.com> <4ED5C047.6040500@linux.vnet.ibm.com> <20111130062502.68d9db59@tlielax.poochiereds.net> <4ED81077.2080305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux PM mailing list <linux-pm@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Belisko Marek <marek.belisko@gmail.com>,
	linux-cifs@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, davem@davemloft.net
To: Woody Suwalski <terraluna977@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ED81077.2080305@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/2011 05:10 AM, Woody Suwalski wrote:

> Jeff Layton wrote:
>> On Wed, 30 Nov 2011 11:03:59 +0530
>> "Srivatsa S. Bhat"<srivatsa.bhat@linux.vnet.ibm.com>  wrote:
>>
>>> Adding linux-pm, Jeff Layton and others to CC.
>>>
>>> Regards,
>>> Srivatsa S. Bhat
>>>
>>> On 11/30/2011 05:04 AM, Woody Suwalski wrote:
>>>
>>>> With CIFS mount present, suspend2ram seems to be failing on 3.2.0-rc3.
>>>> It may be similar to recent NFS suspend issues?
>>>>
>>>> I have done couple of suspends, then did mount.cifs (at 555 seconds),
>>>> and then tried suspend again.  The problem is easy to duplicate.
>>>>
>>>> The hardware is a netbook Asus EeePC.
>>>> I guess will find out if:
>>>> - cifs for real 3.2 fixes the problem
>>>> - NFS fix for -rc4 work for CIFS as well...
>>>>
>>>> Thanks, Woody
>>>>
>>>>
>>>> [  153.974532] uhci_hcd 0000:00:1d.1: PCI INT B disabled
>>>> [  153.974578] uhci_hcd 0000:00:1d.0: PCI INT A disabled
>>>> [  153.975774] i915 0000:00:02.0: PCI INT A disabled
>>>> [  153.977210] ACPI handle has no context!
>>>> [  153.977302] atl2 0000:03:00.0: PCI INT A disabled
>>>> [  153.977316] ACPI handle has no context!
>>>> [  154.277181] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
>>>> [  154.288119] PM: suspend of devices complete after 414.210 msecs
>>>> [  154.299212] ehci_hcd 0000:00:1d.7: PME# enabled
>>>> [  154.299257] ehci_hcd 0000:00:1d.7: wake-up capability enabled by
>>>> ACPI
>>>> [  154.310114] uhci_hcd 0000:00:1d.3: wake-up capability enabled by
>>>> ACPI
>>>> [  154.310178] uhci_hcd 0000:00:1d.2: wake-up capability enabled by
>>>> ACPI
>>>> [  154.310235] uhci_hcd 0000:00:1d.1: wake-up capability enabled by
>>>> ACPI
>>>> [  154.310293] uhci_hcd 0000:00:1d.0: wake-up capability enabled by
>>>> ACPI
>>>> [  154.310418] PM: late suspend of devices complete after 22.283 msecs
>>>> [  154.310451] ACPI: Preparing to enter system sleep state S3
>>>> [  154.311671] PM: Saving platform NVS memory
>>>> [  154.312968] Disabling non-boot CPUs ...
>>>> [  154.312968] ACPI: Low-level resume complete
>>>> [  154.312968] PM: Restoring platform NVS memory
>>>> [  154.312968] Force enabled HPET at resume
>>>> [  154.313366] ACPI: Waking up from system sleep state S3
>>>> [  154.341485] snd_hda_intel 0000:00:1b.0: restoring config space at
>>>> offset 0x1 (was 0x100006, writing 0x100002)
>>>> [  154.341550] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x9 (was 0x1fff1, writing 0x10511041)
>>>> [  154.341566] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x8 (was 0xfff0, writing 0x10301020)
>>>> [  154.341580] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x3030)
>>>> [  154.341603] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x1 (was 0x100104, writing 0x100507)
>>>> [  154.341689] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x9 (was 0x1fff1, writing 0x10111001)
>>>> [  154.341705] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x2020)
>>>> [  154.341728] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x1 (was 0x100106, writing 0x100507)
>>>> [  154.341812] pcieport 0000:00:1c.2: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x1010)
>>>> [  154.341834] pcieport 0000:00:1c.2: restoring config space at offset
>>>> 0x1 (was 0x100106, writing 0x100507)
>>>> [  154.341920] uhci_hcd 0000:00:1d.0: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  154.341958] uhci_hcd 0000:00:1d.0: wake-up capability disabled by
>>>> ACPI
>>>> [  154.342004] uhci_hcd 0000:00:1d.1: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  154.342086] uhci_hcd 0000:00:1d.1: wake-up capability disabled by
>>>> ACPI
>>>> [  154.342137] uhci_hcd 0000:00:1d.2: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  154.342166] uhci_hcd 0000:00:1d.2: wake-up capability disabled by
>>>> ACPI
>>>> [  154.342211] uhci_hcd 0000:00:1d.3: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  154.342239] uhci_hcd 0000:00:1d.3: wake-up capability disabled by
>>>> ACPI
>>>> [  154.342296] ehci_hcd 0000:00:1d.7: restoring config space at offset
>>>> 0x1 (was 0x2900006, writing 0x2900002)
>>>> [  154.342335] ehci_hcd 0000:00:1d.7: wake-up capability disabled by
>>>> ACPI
>>>> [  154.342349] ehci_hcd 0000:00:1d.7: PME# disabled
>>>> [  154.342374] pci 0000:00:1e.0: restoring config space at offset 0xf
>>>> (was 0x60000, writing 0x600ff)
>>>> [  154.342606] atl2 0000:03:00.0: restoring config space at offset 0x1
>>>> (was 0x100006, writing 0x100406)
>>>> [  154.343209] PM: early resume of devices complete after 1.941 msecs
>>>> [  154.343454] i915 0000:00:02.0: PCI INT A ->  GSI 16 (level, low) ->
>>>> IRQ 16
>>>> [  154.343470] i915 0000:00:02.0: setting latency timer to 64
>>>> [  154.347098] snd_hda_intel 0000:00:1b.0: PCI INT A ->  GSI 16 (level,
>>>> low) ->  IRQ 16
>>>> [  154.347117] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
>>>> [  154.347218] snd_hda_intel 0000:00:1b.0: irq 43 for MSI/MSI-X
>>>> [  154.347424] uhci_hcd 0000:00:1d.0: PCI INT A ->  GSI 23 (level, low)
>>>> ->  IRQ 23
>>>> [  154.347442] uhci_hcd 0000:00:1d.0: setting latency timer to 64
>>>> [  154.347479] usb usb2: root hub lost power or was reset
>>>> [  154.347543] uhci_hcd 0000:00:1d.1: PCI INT B ->  GSI 19 (level, low)
>>>> ->  IRQ 19
>>>> [  154.347559] uhci_hcd 0000:00:1d.1: setting latency timer to 64
>>>> [  154.347593] usb usb3: root hub lost power or was reset
>>>> [  154.347653] uhci_hcd 0000:00:1d.2: PCI INT C ->  GSI 18 (level, low)
>>>> ->  IRQ 18
>>>> [  154.347670] uhci_hcd 0000:00:1d.2: setting latency timer to 64
>>>> [  154.347702] usb usb4: root hub lost power or was reset
>>>> [  154.347760] uhci_hcd 0000:00:1d.3: PCI INT D ->  GSI 16 (level, low)
>>>> ->  IRQ 16
>>>> [  154.347776] uhci_hcd 0000:00:1d.3: setting latency timer to 64
>>>> [  154.347808] usb usb5: root hub lost power or was reset
>>>> [  154.347867] ehci_hcd 0000:00:1d.7: PCI INT A ->  GSI 23 (level, low)
>>>> ->  IRQ 23
>>>> [  154.347884] ehci_hcd 0000:00:1d.7: setting latency timer to 64
>>>> [  154.347988] pci 0000:00:1e.0: setting latency timer to 64
>>>> [  154.348125] ata_piix 0000:00:1f.2: PCI INT B ->  GSI 19 (level, low)
>>>> ->  IRQ 19
>>>> [  154.348140] ata_piix 0000:00:1f.2: setting latency timer to 64
>>>> [  154.354172] atl2 0000:03:00.0: PCI INT A ->  GSI 17 (level, low) ->
>>>> IRQ 17
>>>> [  154.354192] atl2 0000:03:00.0: setting latency timer to 64
>>>> [  154.354309] atl2 0000:03:00.0: irq 44 for MSI/MSI-X
>>>> [  154.354722] sd 1:0:0:0: [sda] Starting disk
>>>> [  154.525453] ata2.00: ACPI cmd ef/03:44:00:00:00:a0 (SET FEATURES)
>>>> filtered out
>>>> [  154.525470] ata2.00: ACPI cmd ef/03:0c:00:00:00:a0 (SET FEATURES)
>>>> filtered out
>>>> [  154.531325] ata2.00: configured for UDMA/66
>>>> [  154.591089] usb 1-5: reset high-speed USB device number 2 using
>>>> ehci_hcd
>>>> [  154.805066] PM: resume of devices complete after 461.739 msecs
>>>> [  154.805801] Restarting tasks ... done.
>>>> [  154.832376] video LNXVIDEO:00: Restoring backlight state
>>>> [  155.964388] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
>>>> [  265.377852] PM: Syncing filesystems ... done.
>>>> [  265.427397] Freezing user space processes ... (elapsed 0.01 seconds)
>>>> done.
>>>> [  265.438118] Freezing remaining freezable tasks ... (elapsed 0.01
>>>> seconds) done.
>>>> [  265.449211] Suspending console(s) (use no_console_suspend to debug)
>>>> [  265.451744] sd 1:0:0:0: [sda] Stopping disk
>>>> [  265.555169] ata_piix 0000:00:1f.2: PCI INT B disabled
>>>> [  265.555281] ehci_hcd 0000:00:1d.7: PCI INT A disabled
>>>> [  265.555336] uhci_hcd 0000:00:1d.3: PCI INT D disabled
>>>> [  265.555384] uhci_hcd 0000:00:1d.2: PCI INT C disabled
>>>> [  265.555432] uhci_hcd 0000:00:1d.1: PCI INT B disabled
>>>> [  265.555479] uhci_hcd 0000:00:1d.0: PCI INT A disabled
>>>> [  265.555639] snd_hda_intel 0000:00:1b.0: PCI INT A disabled
>>>> [  265.556302] i915 0000:00:02.0: PCI INT A disabled
>>>> [  265.558207] ACPI handle has no context!
>>>> [  265.558302] atl2 0000:03:00.0: PCI INT A disabled
>>>> [  265.558316] ACPI handle has no context!
>>>> [  265.569117] PM: suspend of devices complete after 119.214 msecs
>>>> [  265.580216] ehci_hcd 0000:00:1d.7: PME# enabled
>>>> [  265.580261] ehci_hcd 0000:00:1d.7: wake-up capability enabled by
>>>> ACPI
>>>> [  265.591121] uhci_hcd 0000:00:1d.3: wake-up capability enabled by
>>>> ACPI
>>>> [  265.591186] uhci_hcd 0000:00:1d.2: wake-up capability enabled by
>>>> ACPI
>>>> [  265.591244] uhci_hcd 0000:00:1d.1: wake-up capability enabled by
>>>> ACPI
>>>> [  265.591302] uhci_hcd 0000:00:1d.0: wake-up capability enabled by
>>>> ACPI
>>>> [  265.591581] PM: late suspend of devices complete after 22.446 msecs
>>>> [  265.591615] ACPI: Preparing to enter system sleep state S3
>>>> [  265.592832] PM: Saving platform NVS memory
>>>> [  265.594133] Disabling non-boot CPUs ...
>>>> [  265.594133] ACPI: Low-level resume complete
>>>> [  265.594133] PM: Restoring platform NVS memory
>>>> [  265.594133] Force enabled HPET at resume
>>>> [  265.594133] ACPI: Waking up from system sleep state S3
>>>> [  265.621463] snd_hda_intel 0000:00:1b.0: restoring config space at
>>>> offset 0x1 (was 0x100006, writing 0x100002)
>>>> [  265.621528] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x9 (was 0x1fff1, writing 0x10511041)
>>>> [  265.621544] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x8 (was 0xfff0, writing 0x10301020)
>>>> [  265.621559] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x3030)
>>>> [  265.621582] pcieport 0000:00:1c.0: restoring config space at offset
>>>> 0x1 (was 0x100104, writing 0x100507)
>>>> [  265.621667] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x9 (was 0x1fff1, writing 0x10111001)
>>>> [  265.621684] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x2020)
>>>> [  265.621706] pcieport 0000:00:1c.1: restoring config space at offset
>>>> 0x1 (was 0x100106, writing 0x100507)
>>>> [  265.621791] pcieport 0000:00:1c.2: restoring config space at offset
>>>> 0x7 (was 0xf0, writing 0x1010)
>>>> [  265.621813] pcieport 0000:00:1c.2: restoring config space at offset
>>>> 0x1 (was 0x100106, writing 0x100507)
>>>> [  265.621899] uhci_hcd 0000:00:1d.0: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  265.621938] uhci_hcd 0000:00:1d.0: wake-up capability disabled by
>>>> ACPI
>>>> [  265.621983] uhci_hcd 0000:00:1d.1: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  265.622057] uhci_hcd 0000:00:1d.1: wake-up capability disabled by
>>>> ACPI
>>>> [  265.622111] uhci_hcd 0000:00:1d.2: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  265.622139] uhci_hcd 0000:00:1d.2: wake-up capability disabled by
>>>> ACPI
>>>> [  265.622183] uhci_hcd 0000:00:1d.3: restoring config space at offset
>>>> 0x1 (was 0x2800005, writing 0x2800001)
>>>> [  265.622210] uhci_hcd 0000:00:1d.3: wake-up capability disabled by
>>>> ACPI
>>>> [  265.622267] ehci_hcd 0000:00:1d.7: restoring config space at offset
>>>> 0x1 (was 0x2900006, writing 0x2900002)
>>>> [  265.622305] ehci_hcd 0000:00:1d.7: wake-up capability disabled by
>>>> ACPI
>>>> [  265.622320] ehci_hcd 0000:00:1d.7: PME# disabled
>>>> [  265.622344] pci 0000:00:1e.0: restoring config space at offset 0xf
>>>> (was 0x60000, writing 0x600ff)
>>>> [  265.622575] atl2 0000:03:00.0: restoring config space at offset 0x1
>>>> (was 0x100006, writing 0x100406)
>>>> [  265.623172] PM: early resume of devices complete after 1.925 msecs
>>>> [  265.623416] i915 0000:00:02.0: PCI INT A ->  GSI 16 (level, low) ->
>>>> IRQ 16
>>>> [  265.623432] i915 0000:00:02.0: setting latency timer to 64
>>>> [  265.627096] snd_hda_intel 0000:00:1b.0: PCI INT A ->  GSI 16 (level,
>>>> low) ->  IRQ 16
>>>> [  265.627115] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
>>>> [  265.627215] snd_hda_intel 0000:00:1b.0: irq 43 for MSI/MSI-X
>>>> [  265.627429] uhci_hcd 0000:00:1d.0: PCI INT A ->  GSI 23 (level, low)
>>>> ->  IRQ 23
>>>> [  265.627448] uhci_hcd 0000:00:1d.0: setting latency timer to 64
>>>> [  265.627485] usb usb2: root hub lost power or was reset
>>>> [  265.627548] uhci_hcd 0000:00:1d.1: PCI INT B ->  GSI 19 (level, low)
>>>> ->  IRQ 19
>>>> [  265.627564] uhci_hcd 0000:00:1d.1: setting latency timer to 64
>>>> [  265.627597] usb usb3: root hub lost power or was reset
>>>> [  265.627659] uhci_hcd 0000:00:1d.2: PCI INT C ->  GSI 18 (level, low)
>>>> ->  IRQ 18
>>>> [  265.627675] uhci_hcd 0000:00:1d.2: setting latency timer to 64
>>>> [  265.627707] usb usb4: root hub lost power or was reset
>>>> [  265.627766] uhci_hcd 0000:00:1d.3: PCI INT D ->  GSI 16 (level, low)
>>>> ->  IRQ 16
>>>> [  265.627781] uhci_hcd 0000:00:1d.3: setting latency timer to 64
>>>> [  265.627814] usb usb5: root hub lost power or was reset
>>>> [  265.627873] ehci_hcd 0000:00:1d.7: PCI INT A ->  GSI 23 (level, low)
>>>> ->  IRQ 23
>>>> [  265.627889] ehci_hcd 0000:00:1d.7: setting latency timer to 64
>>>> [  265.627993] pci 0000:00:1e.0: setting latency timer to 64
>>>> [  265.628130] ata_piix 0000:00:1f.2: PCI INT B ->  GSI 19 (level, low)
>>>> ->  IRQ 19
>>>> [  265.628145] ata_piix 0000:00:1f.2: setting latency timer to 64
>>>> [  265.634153] atl2 0000:03:00.0: PCI INT A ->  GSI 17 (level, low) ->
>>>> IRQ 17
>>>> [  265.634173] atl2 0000:03:00.0: setting latency timer to 64
>>>> [  265.634290] atl2 0000:03:00.0: irq 44 for MSI/MSI-X
>>>> [  265.634712] sd 1:0:0:0: [sda] Starting disk
>>>> [  265.796709] ata2.00: ACPI cmd ef/03:44:00:00:00:a0 (SET FEATURES)
>>>> filtered out
>>>> [  265.796726] ata2.00: ACPI cmd ef/03:0c:00:00:00:a0 (SET FEATURES)
>>>> filtered out
>>>> [  265.803326] ata2.00: configured for UDMA/66
>>>> [  265.880091] usb 1-5: reset high-speed USB device number 2 using
>>>> ehci_hcd
>>>> [  266.091960] PM: resume of devices complete after 468.673 msecs
>>>> [  266.092731] Restarting tasks ... done.
>>>> [  266.112098] video LNXVIDEO:00: Restoring backlight state
>>>> [  267.219459] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
>>>> [  554.912659] FS-Cache: Loaded
>>>> [  554.950749] FS-Cache: Netfs 'cifs' registered for caching
>>>> [  555.047550] CIFS VFS: default security mechanism requested.  The
>>>> default security mechanism will be upgraded from ntlm to ntlmv2 in
>>>> kernel release 3.2
>>>> [ 2094.090461] PM: Syncing filesystems ... done.
>>>> [ 2094.155385] Freezing user space processes ... (elapsed 0.01 seconds)
>>>> done.
>>>> [ 2094.166113] Freezing remaining freezable tasks ...
>>>> [ 2114.175108] Freezing of tasks failed after 20.00 seconds (1 tasks
>>>> refusing to freeze, wq_busy=0):
>>>> [ 2114.175586] cifsd           S ccb50b40     0  2219      2 0x00800000
>>>> [ 2114.175611]  cc6cc000 00000046 00000000 ccb50b40 cc776b40 cc41d000
>>>> cc776780 cc61d960
>>>> [ 2114.175635]  cc4d81c0 c178ec40 c178ec40 ccb50980 00000000 ccb50980
>>>> c1031e88 00000001
>>>> [ 2114.175660]  c1031f9f c10230f5 c1559ee1 c17a7140 c1031e88 00000001
>>>> c1031f9f c10230f5
>>>> [ 2114.175684] Call Trace:
>>>> [ 2114.175710]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.175723]  [<c1031f9f>] ? add_preempt_count+0x5f/0xa0
>>>> [ 2114.175747]  [<c10230f5>] ? default_spin_lock_flags+0x5/0x10
>>>> [ 2114.175770]  [<c1559ee1>] ? _raw_spin_lock_irqsave+0x31/0x50
>>>> [ 2114.175782]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.175794]  [<c1031f9f>] ? add_preempt_count+0x5f/0xa0
>>>> [ 2114.175807]  [<c10230f5>] ? default_spin_lock_flags+0x5/0x10
>>>> [ 2114.175820]  [<c1559ee1>] ? _raw_spin_lock_irqsave+0x31/0x50
>>>> [ 2114.175832]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.175846]  [<c15588c1>] ? schedule_timeout+0x111/0x1d0
>>>> [ 2114.175860]  [<c1512500>] ? tcp_rcv_established+0x170/0x760
>>>> [ 2114.175878]  [<c1041fa0>] ? usleep_range+0x40/0x40
>>>> [ 2114.175897]  [<c14cb6e7>] ? sk_wait_data+0xa7/0xb0
>>>> [ 2114.175920]  [<c104ffc0>] ? abort_exclusive_wait+0x90/0x90
>>>> [ 2114.175943]  [<c1509948>] ? tcp_recvmsg+0x588/0xb80
>>>> [ 2114.175956]  [<c1001c0a>] ? __switch_to+0xea/0x1d0
>>>> [ 2114.175976]  [<c1008e97>] ? native_sched_clock+0x27/0x90
>>>> [ 2114.175993]  [<c152685f>] ? inet_recvmsg+0x6f/0xb0
>>>> [ 2114.176063]  [<c14c7f70>] ? sock_recvmsg+0xe0/0x120
>>>> [ 2114.176086]  [<c1242df8>] ? timerqueue_add+0x58/0xb0
>>>> [ 2114.176098]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.176112]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.176123]  [<c1031f07>] ? sub_preempt_count+0x67/0xa0
>>>> [ 2114.176145]  [<c1559d1b>] ? _raw_spin_unlock_irqrestore+0x1b/0x40
>>>> [ 2114.176165]  [<c1053a43>] ? hrtimer_try_to_cancel+0x43/0xa0
>>>> [ 2114.176178]  [<c1053ab1>] ? hrtimer_cancel+0x11/0x20
>>>> [ 2114.176191]  [<c155934c>] ?
>>>> schedule_hrtimeout_range_clock+0xcc/0x170
>>>> [ 2114.176206]  [<c10536c0>] ? update_rmtp+0x80/0x80
>>>> [ 2114.176219]  [<c14c7fe7>] ? kernel_recvmsg+0x37/0x50
>>>> [ 2114.176268]  [<d0611228>] ? cifs_readv_from_socket+0x148/0x2b0
>>>> [cifs]
>>>> [ 2114.176283]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.176309]  [<d06113ac>] ? cifs_read_from_socket+0x1c/0x20 [cifs]
>>>> [ 2114.176333]  [<d0611522>] ? cifs_demultiplex_thread+0x112/0xc20
>>>> [cifs]
>>>> [ 2114.176348]  [<c1031e88>] ? get_parent_ip+0x8/0x20
>>>> [ 2114.176370]  [<d0611410>] ? dequeue_mid+0x60/0x60 [cifs]
>>>> [ 2114.176391]  [<c104f9c9>] ? kthread+0x69/0x70
>>>> [ 2114.176406]  [<c104f960>] ? kthread_worker_fn+0x150/0x150
>>>> [ 2114.176420]  [<c155af76>] ? kernel_thread_helper+0x6/0xd
>>>> [ 2114.176466]
>>>> [ 2114.176473] Restarting tasks ... done.
>>>> [ 2114.201577] video LNXVIDEO:00: Restoring backlight state
>>>> [ 2114.210975] lxpanel[1452]: segfault at 0 ip b6ead703 sp bfea8924
>>>> error 4 in libc-2.13.so[b6e39000+13e000]
>>>> -- 
>> Thanks for reporting this. Does the following patch fix it?
>>
>> -----------------------[snip]------------------------
>>
>> cifs: attempt to freeze while looping on a receive attempt
>>
>> In the recent overhaul of the demultiplex thread receive path, we
>> neglected to ensure that we attempt to freeze on each pass through the
>> loop.
>>
>> Reported-by: Woody Suwalski<terraluna977@gmail.com>
>> Signed-off-by: Jeff Layton<jlayton@redhat.com>
>> ---
>>   fs/cifs/connect.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
>> index bf82f88..d166e3a 100644
>> --- a/fs/cifs/connect.c
>> +++ b/fs/cifs/connect.c
>> @@ -441,6 +441,8 @@ cifs_readv_from_socket(struct TCP_Server_Info
>> *server, struct kvec *iov_orig,
>>       smb_msg.msg_controllen = 0;
>>
>>       for (total_read = 0; to_read; total_read += length, to_read -=
>> length) {
>> +        try_to_freeze();
>> +
>>           if (server_unresponsive(server)) {
>>               total_read = -EAGAIN;
>>               break;
> Jeff, the patch does work (if a right module is insmoded ;-) )
> 


Nice! And what a relief, it really works as expected :-)

And the other stack trace that Jeff gave a link to is much more clear
and makes it pretty evident that kernel_recvmsg really is the culprit.

By the way, that makes me wonder, CIFS might not be the only instance for
freezing failures like this. So, there might be other places in the
kernel where this problem exists, which we haven't hit yet.

In general, going by what was analysed in this thread, calling
kernel_recvmsg() in a loop without a try_to_freeze(), anywhere in the
kernel (other than cifs too), could potentially cause freezing failures,
since kernel_recvmsg could end up sleeping for long durations (couple of
seconds).

So how about solving this problem more fundamentally, such as defining a
freezable wrapper over kernel_recvmsg like:

#define kernel_recvmsg_freezable(sock, msg, vec, num, size, flags)      \
({                                                                      \
        kernel_recvmsg(sock, msg, vec, num, size, flags)                \
	try_to_freeze();                                                \
})

and using it instead of kernel_recvmsg(), throughout the kernel?

But kernel_recvmsg is an exported symbol. So if we are very very unwilling
to change the kernel ABI, we could probably think about adding try_to_freeze()
inside kernel_recvmsg itself,like this (but see below about my thoughts about
which one is better):

---

 net/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 2877647..8d80e4f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -88,6 +88,7 @@
 #include <linux/nsproxy.h>
 #include <linux/magic.h>
 #include <linux/slab.h>
+#include <linux/freezer.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -774,6 +775,13 @@ int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 	msg->msg_iov = (struct iovec *)vec, msg->msg_iovlen = num;
 	result = sock_recvmsg(sock, msg, size, flags);
 	set_fs(oldfs);
+
+	/*
+	 * We might sleep in the above code for a long time (a couple of
+	 * seconds), which could cause freezing failures if the caller calls us
+	 * in a loop. So cooperate with the freezer here itself.
+         */
+	try_to_freeze();
 	return result;
 }
 EXPORT_SYMBOL(kernel_recvmsg);


I don't think it is such a good idea to silently call try_to_freeze() in
kernel_recvmsg like what the above code does. So I would rather prefer adding
the freezable wrapper and exporting it, though it amounts to an ABI change.


By the way, coming back to the idea of adding try_to_freeze() fundamentally,
these are the advantages [irrespective of which of the 2 above mentioned
implementation approaches we use]: (For now, lets assume we use the wrapper method)

1. If somebody calls this in a loop without calling try_to_freeze() (like
   what CIFS did originally), we are still OK, we won't cause freezing
   failure. And forgetting try_to_freeze() is probably a common mistake,
   so we safeguard against that automatically.

2. If a non-freezable entity (such as a kernel thread that didn't call
   set_freezable() on purpose) uses this function, then that won't hurt it
   either, because the try_to_freeze() won't do anything and will simply
   return (because the freezer skips non-freezable tasks).

Now the only question that might pop up is, is there any case where we
specifically *do not* want to get frozen immediately after kernel_recvmsg?
(for whatever reason).

[CC'ing David Miller, Greg K-H and netdev mailing list, for comments].

I don't know of any such cases, so my assumption is that using the above
wrapper is safe in all cases. And since this wrapper prevents freezing
failures, it should be recommended over directly using kernel_recvmsg,
and also, all present users of kernel_recvmsg must be modified to use the
above wrapper, unless some code has a specific reason to directly use
kernel_recvmsg.

Rafael, Tejun, let me know what you think of this idea. If it sounds good,
I'll write it up as a formal patch and post it.

Thanks,
Srivatsa S. Bhat
