From: Paul Menzel <paulepanter@users.sourceforge.net>
Subject: atl2: NETDEV WATCHDOG: eth0 (atl2): transmit queue 0 timed out
Date: Sat, 05 Oct 2013 16:26:53 +0200
Message-ID: <1380983213.5187.7.camel@mattotaupa>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-qSOJ4KreIo3eDExSLPeX"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gw90.de ([188.40.100.199]:56016 "EHLO mail.gw90.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab3JEOo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Oct 2013 10:44:57 -0400
Received: from cable-89-16-137-11.cust.telecolumbus.net ([89.16.137.11] helo=[192.168.1.14])
	by mail.gw90.de with esmtpsa (TLS1.0:DHE_RSA_CAMELLIA_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <paulepanter@users.sourceforge.net>)
	id 1VSSp0-00037s-5J
	for netdev@vger.kernel.org; Sat, 05 Oct 2013 14:27:06 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qSOJ4KreIo3eDExSLPeX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Linux folks,


using the ASUS Eee PC 701 4G, I experienced the first time, that I had
problems with an Ethernet connection. It was in a cooperate network
using a lot of switches and other gear I suppose. Though I do not know
the details and it should not matter. The laptop even locked up after a
while and had to be reset, but I do not have a backtrace for that.

Debian Sid/unstable is used on the system and I only now found time to
report it. Should I open a bug in Linux=E2=80=99 Bugzilla about that or is =
it
not enough information. In the latter case I do not have access to the
network anymore, so testing/debugging would be difficult.


Thanks,

Paul


Aug 20 10:50:11 myhostname kernel: [ 1029.595180] IPv6: ADDRCONF(NETDEV_UP)=
: wlan0: link is not ready
Aug 20 10:51:24 myhostname kernel: [ 1103.008058] ------------[ cut here ]-=
-----------
Aug 20 10:51:24 myhostname kernel: [ 1103.008097] WARNING: at /build/linux-=
mt4E4Z/linux-3.10.7/net/sched/sch_generic.c:255 dev_watchdog+0xae/0x111()
Aug 20 10:51:24 myhostname kernel: [ 1103.008106] NETDEV WATCHDOG: eth0 (at=
l2): transmit queue 0 timed out
Aug 20 10:51:24 myhostname kernel: [ 1103.008112] Modules linked in: arc4 a=
th5k ath mac80211 cfg80211 cuse uinput loop fuse joydev iTCO_wdt snd_hda_co=
dec_realtek iTCO_vendor_support mperf hid_generic snd_hda_intel snd_hda_cod=
ec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc usb_storage s=
nd_seq_midi snd_seq_midi_event microcode snd_rawmidi psmouse evdev serio_ra=
w usbhid lpc_ich mfd_core hid rng_core snd_seq snd_seq_device snd_timer i91=
5 battery snd ac video drm_kms_helper drm eeepc_laptop sparse_keymap i2c_al=
go_bit soundcore rfkill processor i2c_core button ext3 mbcache jbd sg sd_mo=
d crc_t10dif ata_generic ata_piix ahci libahci libata ehci_pci uhci_hcd ehc=
i_hcd scsi_mod usbcore usb_common atl2 thermal thermal_sys
Aug 20 10:51:24 myhostname kernel: [ 1103.008287] CPU: 0 PID: 0 Comm: swapp=
er/0 Not tainted 3.10-2-686-pae #1 Debian 3.10.7-1
Aug 20 10:51:24 myhostname kernel: [ 1103.008295] Hardware name: ASUSTeK Co=
mputer INC. 701/701, BIOS 0801    01/08/2008
Aug 20 10:51:24 myhostname kernel: [ 1103.008303]  00000000 c102ff24 c1269f=
93 dc1a4800 00000000 00031030 dc1a4a28 c102ff9f
Aug 20 10:51:24 myhostname kernel: [ 1103.008321]  00000009 c1437eac c13fbf=
b6 c1437ec4 c1269f93 c13fbfef 000000ff c13fbfb6
Aug 20 10:51:24 myhostname kernel: [ 1103.008338]  dc1a4800 dffc45b8 000000=
00 c1530840 00000100 c1269ee5 c1039ee5 c1530840
Aug 20 10:51:24 myhostname kernel: [ 1103.008356] Call Trace:
Aug 20 10:51:24 myhostname kernel: [ 1103.008375]  [<c102ff24>] ? warn_slow=
path_common+0x4d/0x60
Aug 20 10:51:24 myhostname kernel: [ 1103.008387]  [<c1269f93>] ? dev_watch=
dog+0xae/0x111
Aug 20 10:51:24 myhostname kernel: [ 1103.008400]  [<c102ff9f>] ? warn_slow=
path_fmt+0x29/0x2d
Aug 20 10:51:24 myhostname kernel: [ 1103.008411]  [<c1269f93>] ? dev_watch=
dog+0xae/0x111
Aug 20 10:51:24 myhostname kernel: [ 1103.008429]  [<c1269ee5>] ? netif_tx_=
lock+0x5d/0x5d
Aug 20 10:51:24 myhostname kernel: [ 1103.008443]  [<c1039ee5>] ? call_time=
r_fn+0x37/0xb7
Aug 20 10:51:24 myhostname kernel: [ 1103.008454]  [<c1269ee5>] ? netif_tx_=
lock+0x5d/0x5d
Aug 20 10:51:24 myhostname kernel: [ 1103.008465]  [<c103ac3e>] ? run_timer=
_softirq+0x15d/0x198
Aug 20 10:51:24 myhostname kernel: [ 1103.008477]  [<c1035d42>] ? __do_soft=
irq+0xc2/0x1be
Aug 20 10:51:24 myhostname kernel: [ 1103.008488]  [<c1035ef1>] ? irq_exit+=
0x37/0x6f
Aug 20 10:51:24 myhostname kernel: [ 1103.008502]  [<c100acef>] ? do_IRQ+0x=
65/0x76
Aug 20 10:51:24 myhostname kernel: [ 1103.008517]  [<c12fff73>] ? common_in=
terrupt+0x33/0x38
Aug 20 10:51:24 myhostname kernel: [ 1103.008533]  [<c10600d8>] ? swsusp_wr=
ite+0x203/0x3b1
Aug 20 10:51:24 myhostname kernel: [ 1103.008547]  [<c123eba1>] ? arch_loca=
l_irq_enable+0x2/0x7
Aug 20 10:51:24 myhostname kernel: [ 1103.008559]  [<c123ef00>] ? cpuidle_e=
nter_state+0x45/0xac
Aug 20 10:51:24 myhostname kernel: [ 1103.008575]  [<c123f012>] ? cpuidle_i=
dle_call+0xab/0x10b
Aug 20 10:51:24 myhostname kernel: [ 1103.008588]  [<c100eff3>] ? arch_cpu_=
idle+0x5/0x15
Aug 20 10:51:24 myhostname kernel: [ 1103.008600]  [<c1060ce2>] ? cpu_start=
up_entry+0xff/0x17a
Aug 20 10:51:24 myhostname kernel: [ 1103.008613]  [<c1489965>] ? start_ker=
nel+0x356/0x35b
Aug 20 10:51:24 myhostname kernel: [ 1103.008620] ---[ end trace 28eba49339=
6f44b7 ]---
Aug 20 10:51:25 myhostname kernel: [ 1103.024326] atl2: eth0 NIC Link is Up=
<100 Mbps Full Duplex>
Aug 20 10:51:25 myhostname kernel: [ 1103.646328] eth0: txs packet size not=
 consistent with txd txd_:0x06707474, txs_:0x0001004b!
Aug 20 10:51:25 myhostname kernel: [ 1103.646340] txd read ptr: 0x54
Aug 20 10:51:25 myhostname kernel: [ 1103.646346] txs-behind:0x8001004b
Aug 20 10:51:25 myhostname kernel: [ 1103.646351] txs-before:0x0001004d
Aug 20 10:51:25 myhostname kernel: [ 1103.646359] eth0: txs packet size not=
 consistent with txd txd_:0x01400001, txs_:0x0001004b!
Aug 20 10:51:25 myhostname kernel: [ 1103.646365] txd read ptr: 0x4cc
Aug 20 10:51:25 myhostname kernel: [ 1103.646370] txs-behind:0x8001004d
Aug 20 10:51:25 myhostname kernel: [ 1103.646375] txs-before:0x0001004b
Aug 20 10:51:25 myhostname kernel: [ 1103.646383] eth0: txs packet size not=
 consistent with txd txd_:0x070c0000, txs_:0x0001004d!
Aug 20 10:51:25 myhostname kernel: [ 1103.646388] txd read ptr: 0x4d4
Aug 20 10:51:25 myhostname kernel: [ 1103.646394] txs-behind:0x8001004d
Aug 20 10:51:25 myhostname kernel: [ 1103.646399] txs-before:0x0001004b
Aug 20 10:51:25 myhostname kernel: [ 1103.646406] eth0: txs packet size not=
 consistent with txd txd_:0x1f0001ac, txs_:0x0001004d!
Aug 20 10:51:25 myhostname kernel: [ 1103.646412] txd read ptr: 0x4d8
Aug 20 10:51:25 myhostname kernel: [ 1103.646417] txs-behind:0x0001017b
Aug 20 10:51:25 myhostname kernel: [ 1103.646422] txs-before:0x0001004d
Aug 20 10:51:35 myhostname kernel: [ 1113.024274] atl2: eth0 NIC Link is Up=
<100 Mbps Full Duplex>
Aug 20 10:51:35 myhostname kernel: [ 1113.032039] eth0: txs packet size not=
 consistent with txd txd_:0x1f0001ac, txs_:0x0003002a!
Aug 20 10:51:35 myhostname kernel: [ 1113.032051] txd read ptr: 0xe0
Aug 20 10:51:35 myhostname kernel: [ 1113.032056] txs-behind:0x8001004d
Aug 20 10:51:35 myhostname kernel: [ 1113.032062] txs-before:0x00010069
Aug 20 10:51:35 myhostname kernel: [ 1113.032070] eth0: txs packet size not=
 consistent with txd txd_:0x6f673278, txs_:0x0001004d!
Aug 20 10:51:35 myhostname kernel: [ 1113.032075] txd read ptr: 0x290
Aug 20 10:51:35 myhostname kernel: [ 1113.032081] txs-behind:0x0001004d
Aug 20 10:51:35 myhostname kernel: [ 1113.032086] txs-before:0x0003002a
Aug 20 10:51:45 myhostname kernel: [ 1123.024250] atl2: eth0 NIC Link is Up=
<100 Mbps Full Duplex>
Aug 20 10:51:53 myhostname kernel: [ 1131.469794] eth0: txs packet size not=
 consistent with txd txd_:0x11400040, txs_:0x00010042!
Aug 20 10:51:53 myhostname kernel: [ 1131.469808] txd read ptr: 0x2b8
Aug 20 10:51:53 myhostname kernel: [ 1131.469813] txs-behind:0x80010042x

-- Package-specific info:
** Version:
Linux version 3.10-2-686-pae (debian-kernel@lists.debian.org) (gcc version =
4.7.3 (Debian 4.7.3-6) ) #1 SMP Debian 3.10.7-1 (2013-08-17)

** Command line:
BOOT_IMAGE=3D/boot/vmlinuz-3.10-2-686-pae root=3DUUID=3Db33ef3d8-b6d8-481d-=
a9a3-0050047ab9b9 ro quiet noisapnp pcie_aspm=3Dforce

** Not tainted

** Kernel log:
[    2.519556] kjournald starting.  Commit interval 5 seconds
[    2.519625] EXT3-fs (sda1): mounted filesystem with ordered data mode
[    2.621524] usb 2-5: New USB device found, idVendor=3D0951, idProduct=3D=
1606
[    2.621541] usb 2-5: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D4
[    2.621551] usb 2-5: Product: UB6225
[    2.621560] usb 2-5: Manufacturer: ENE
[    2.621569] usb 2-5: SerialNumber: 146030377350
[    3.116128] usb 3-1: new low-speed USB device number 2 using uhci_hcd
[    3.292705] usb 3-1: New USB device found, idVendor=3D03f0, idProduct=3D=
0024
[    3.292722] usb 3-1: New USB device strings: Mfr=3D1, Product=3D2, Seria=
lNumber=3D0
[    3.292733] usb 3-1: Product: HP Basic USB Keyboard
[    3.292742] usb 3-1: Manufacturer: CHICONY
[    3.536162] usb 3-2: new low-speed USB device number 3 using uhci_hcd
[    3.704681] usb 3-2: New USB device found, idVendor=3D0461, idProduct=3D=
4dfb
[    3.704697] usb 3-2: New USB device strings: Mfr=3D0, Product=3D2, Seria=
lNumber=3D0
[    3.704708] usb 3-2: Product: USB Optical Mouse
[    7.620912] udevd[336]: starting version 175
[    8.071184] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:=
00/input/input1
[    8.071793] tsc: Marking TSC unstable due to TSC halts in idle
[    8.071840] ACPI: acpi_idle registered with cpuidle
[    8.075548] ACPI: Lid Switch [LID]
[    8.075874] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0=
E:00/input/input2
[    8.075897] ACPI: Sleep Button [SLPB]
[    8.076465] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0=
C:00/input/input3
[    8.076485] ACPI: Power Button [PWRB]
[    8.092522] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input4
[    8.092545] ACPI: Power Button [PWRF]
[    8.094858] Switching to clocksource hpet
[    8.189205] eeepc_laptop: Eee PC Hotkey Driver
[    8.189223] eeepc_laptop: model 701 does not officially support setting =
cpu speed
[    8.189229] eeepc_laptop: cpufv disabled to avoid instability
[    8.189248] eeepc_laptop: Hotkey init flags 0x41
[    8.190282] eeepc_laptop: Get control methods supported: 0x101711
[    8.208768] [drm] Initialized drm 1.1.0 20060810
[    8.272853] ACPI: Video Device [VGA] (multi-head: yes  rom: no  post: no=
)
[    8.273092] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:0=
0/LNXVIDEO:00/input/input5
[    8.537444] [drm] Memory usable by graphics device =3D 256M
[    8.537474] i915 0000:00:02.0: setting latency timer to 64
[    8.538552] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    8.538563] [drm] Driver supports precise vblank timestamp query.
[    8.539682] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=
=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem
[    8.556115] usb 2-8: new high-speed USB device number 5 using ehci-pci
[    8.592761] intel_rng: FWH not detected
[    8.603673] [drm] initialized overlay support
[    8.610419] hidraw: raw HID events driver (C) Jiri Kosina
[    8.677897] usbcore: registered new interface driver usbhid
[    8.677908] usbhid: USB HID core driver
[    8.744099] usb 2-8: New USB device found, idVendor=3Deb1a, idProduct=3D=
2761
[    8.744116] usb 2-8: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[    8.856698] microcode: CPU0 sig=3D0x6d8, pf=3D0x20, revision=3D0x20
[    8.978580] usb-storage 2-5:1.0: USB Mass Storage device detected
[    9.025880] fbcon: inteldrmfb (fb0) is primary device
[    9.041389] scsi2 : usb-storage 2-5:1.0
[    9.041870] usbcore: registered new interface driver usb-storage
[    9.351807] ACPI: Battery Slot [BAT0] (battery present)
[    9.352224] ACPI: AC Adapter [AC0] (on-line)
[    9.412154] input: CHICONY HP Basic USB Keyboard as /devices/pci0000:00/=
0000:00:1d.1/usb3/3-1/3-1:1.0/input/input6
[    9.413969] hid-generic 0003:03F0:0024.0001: input,hidraw0: USB HID v1.1=
0 Keyboard [CHICONY HP Basic USB Keyboard] on usb-0000:00:1d.1-1/input0
[    9.415362] input: USB Optical Mouse as /devices/pci0000:00/0000:00:1d.1=
/usb3/3-2/3-2:1.0/input/input7
[    9.425070] hid-generic 0003:0461:4DFB.0002: input,hidraw1: USB HID v1.1=
1 Mouse [USB Optical Mouse] on usb-0000:00:1d.1-2/input0
[    9.433381] platform microcode: firmware: agent aborted loading intel-uc=
ode/06-0d-08 (not found?)
[    9.433677] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[   10.040976] scsi 2:0:0:0: Direct-Access     USB2.0   CardReader SD0   01=
00 PQ: 0 ANSI: 0
[   10.044207] sd 2:0:0:0: Attached scsi generic sg1 type 0
[   10.047213] sd 2:0:0:0: [sdb] Attached SCSI removable disk
[   10.088176] psmouse serio1: synaptics: Touchpad model: 1, fw: 6.5, id: 0=
x1c0b1, caps: 0xa04751/0xa00000/0x0, board id: 3655, fw id: 409168
[   10.172072] Console: switching to colour frame buffer device 100x30
[   10.191916] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[   10.191923] i915 0000:00:02.0: registered panic notifier
[   10.199429] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on mi=
nor 0
[   10.199770] ACPI Warning: 0x00000828-0x0000082f SystemIO conflicts with =
Region \PMIO 1 (20130328/utaddress-251)
[   10.199794] ACPI Warning: 0x00000828-0x0000082f SystemIO conflicts with =
Region \_SB_.PCI0.SBRG.PMS0 2 (20130328/utaddress-251)
[   10.199813] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.199824] ACPI Warning: 0x000004b0-0x000004bf SystemIO conflicts with =
Region \_SB_.PCI0.SBRG.GPBX 1 (20130328/utaddress-251)
[   10.199843] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.199850] ACPI Warning: 0x00000480-0x000004af SystemIO conflicts with =
Region \_SB_.PCI0.SBRG.GPBX 1 (20130328/utaddress-251)
[   10.199868] ACPI: If an ACPI driver is available for this device, you sh=
ould use it instead of the native driver
[   10.199876] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   10.252346] snd_hda_intel 0000:00:1b.0: irq 43 for MSI/MSI-X
[   10.253329] iTCO_vendor_support: vendor-support=3D0
[   10.267503] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042=
/serio1/input/input9
[   10.271947] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   10.272193] iTCO_wdt: Found a ICH6-M TCO device (Version=3D2, TCOBASE=3D=
0x0860)
[   10.272550] iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)
[   10.285533] input: Asus EeePC extra buttons as /devices/platform/eeepc/i=
nput/input8
[   10.335377] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.=
0/input/input10
[   10.342031] input: HDA Intel Headphone as /devices/pci0000:00/0000:00:1b=
.0/sound/card0/input11
[   10.342647] input: HDA Intel Mic as /devices/pci0000:00/0000:00:1b.0/sou=
nd/card0/input12
[   10.505827] eeepc_laptop: BIOS says wireless lan is blocked, but the pci=
 device is present
[   10.505841] eeepc_laptop: skipped wireless hotplug as probably inappropr=
iate for this model
[   10.506749] eeepc_laptop: Unable to find port
[   11.403955] EXT3-fs (sda1): using internal journal
[   12.193337] fuse init (API version 7.22)
[   12.289773] loop: module loaded
[   15.619754] input: ACPI Virtual Keyboard Device as /devices/virtual/inpu=
t/input13
[   17.283499] CUSE: failed to register chrdev region
[   18.941624] atl2 0000:03:00.0: irq 44 for MSI/MSI-X
[   18.941794] atl2: eth0 NIC Link is Up<100 Mbps Full Duplex>
[   29.181783] eeepc_laptop: Unknown key 2b pressed
[   29.252726] eeepc_laptop: Unknown key 2e pressed

** Model information
not available

** Loaded modules:
cuse
uinput
loop
fuse
snd_hda_codec_realtek
joydev
iTCO_wdt
iTCO_vendor_support
mperf
hid_generic
snd_hda_intel
snd_hda_codec
snd_hwdep
snd_pcm_oss
snd_mixer_oss
snd_pcm
snd_page_alloc
usb_storage
snd_seq_midi
snd_seq_midi_event
microcode
snd_rawmidi
psmouse
evdev
serio_raw
snd_seq
lpc_ich
usbhid
mfd_core
hid
rng_core
snd_seq_device
snd_timer
i915
ac
battery
video
snd
drm_kms_helper
eeepc_laptop
sparse_keymap
drm
rfkill
i2c_algo_bit
soundcore
button
processor
i2c_core
ext3
mbcache
jbd
sg
sd_mod
crc_t10dif
ata_generic
ata_piix
ahci
libahci
libata
ehci_pci
uhci_hcd
ehci_hcd
scsi_mod
usbcore
usb_common
atl2
thermal
thermal_sys

** PCI devices:
00:00.0 Host bridge [0600]: Intel Corporation Mobile 915GM/PM/GMS/910GML Ex=
press Processor to DRAM Controller [8086:2590] (rev 04)
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d9]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: <access denied>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller [0300]: Intel Corporation Mobile 915GM/GM=
S/910GML Express Graphics Controller [8086:2592] (rev 04) (prog-if 00 [VGA =
controller])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d9]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f7f00000 (32-bit, non-prefetchable) [size=3D512K]
	Region 1: I/O ports at ec00 [size=3D8]
	Region 2: Memory at d0000000 (32-bit, prefetchable) [size=3D256M]
	Region 3: Memory at f7ec0000 (32-bit, non-prefetchable) [size=3D256K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: <access denied>
	Kernel driver in use: i915

00:02.1 Display controller [0380]: Intel Corporation Mobile 915GM/GMS/910GM=
L Express Graphics Controller [8086:2792] (rev 04)
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d9]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at f7f80000 (32-bit, non-prefetchable) [size=3D512K]
	Capabilities: <access denied>

00:1b.0 Audio device [0403]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 =
Family) High Definition Audio Controller [8086:2668] (rev 04)
	Subsystem: ASUSTeK Computer Inc. Device [1043:82a1]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Interrupt: pin A routed to IRQ 43
	Region 0: Memory at f7eb8000 (64-bit, non-prefetchable) [size=3D16K]
	Capabilities: <access denied>
	Kernel driver in use: snd_hda_intel

00:1c.0 PCI bridge [0604]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Fa=
mily) PCI Express Port 1 [8086:2660] (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Bus: primary=3D00, secondary=3D04, subordinate=3D04, sec-latency=3D0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: 1f900000-1fafffff
	Prefetchable memory behind bridge: 000000001fb00000-000000001fcfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.1 PCI bridge [0604]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Fa=
mily) PCI Express Port 2 [8086:2662] (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Bus: primary=3D00, secondary=3D03, subordinate=3D03, sec-latency=3D0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: fbf00000-fbffffff
	Prefetchable memory behind bridge: 000000001fd00000-000000001fefffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1c.2 PCI bridge [0604]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Fa=
mily) PCI Express Port 3 [8086:2664] (rev 04) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Bus: primary=3D00, secondary=3D01, subordinate=3D02, sec-latency=3D0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f8000000-fbefffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f6ffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:1d.0 USB controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #1 [8086:2658] (rev 04) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at e400 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.1 USB controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #2 [8086:2659] (rev 04) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at e480 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.2 USB controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #3 [8086:265a] (rev 04) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at e800 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.3 USB controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB UHCI #4 [8086:265b] (rev 04) (prog-if 00 [UHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 16
	Region 4: I/O ports at e880 [size=3D32]
	Kernel driver in use: uhci_hcd

00:1d.7 USB controller [0c03]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH=
6 Family) USB2 EHCI Controller [8086:265c] (rev 04) (prog-if 20 [EHCI])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at f7eb7c00 (32-bit, non-prefetchable) [size=3D1K]
	Capabilities: <access denied>
	Kernel driver in use: ehci-pci

00:1e.0 PCI bridge [0604]: Intel Corporation 82801 Mobile PCI Bridge [8086:=
2448] (rev d4) (prog-if 01 [Subtractive decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=3D00, secondary=3D05, subordinate=3D05, sec-latency=3D32
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

00:1f.0 ISA bridge [0601]: Intel Corporation 82801FBM (ICH6M) LPC Interface=
 Bridge [8086:2641] (rev 04)
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Kernel driver in use: lpc_ich

00:1f.2 IDE interface [0101]: Intel Corporation 82801FBM (ICH6M) SATA Contr=
oller [8086:2653] (rev 04) (prog-if 80 [Master])
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 0: I/O ports at 01f0 [size=3D8]
	Region 1: I/O ports at 03f4
	Region 2: I/O ports at 0170 [size=3D8]
	Region 3: I/O ports at 0374
	Region 4: I/O ports at ffa0 [size=3D16]
	Capabilities: <access denied>
	Kernel driver in use: ata_piix

00:1f.3 SMBus [0c05]: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)=
 SMBus Controller [8086:266a] (rev 04)
	Subsystem: ASUSTeK Computer Inc. Device [1043:82d8]
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbort=
- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 0
	Region 4: I/O ports at 0400 [size=3D32]

03:00.0 Ethernet controller [0200]: Qualcomm Atheros Attansic L2 Fast Ether=
net [1969:2048] (rev a0)
	Subsystem: ASUSTeK Computer Inc. Device [1043:8233]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Steppi=
ng- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbort- =
<MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Interrupt: pin A routed to IRQ 44
	Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=3D256K]
	Expansion ROM at fbfa0000 [disabled] [size=3D128K]
	Capabilities: <access denied>
	Kernel driver in use: atl2


** USB devices:
Bus 002 Device 005: ID eb1a:2761 eMPIA Technology, Inc. EeePC 701 integrate=
d Webcam
Bus 002 Device 004: ID 0951:1606 Kingston Technology Eee PC 701 SD Card Rea=
der [ENE UB6225]
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 003: ID 0461:4dfb Primax Electronics, Ltd=20
Bus 003 Device 002: ID 03f0:0024 Hewlett-Packard KU-0316 Keyboard
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub


-- System Information:
Debian Release: jessie/sid
  APT prefers unstable
  APT policy: (500, 'unstable')
Architecture: i386 (i686)

Kernel: Linux 3.10-2-686-pae (SMP w/1 CPU core)
Locale: LANG=3Dde_DE.UTF-8, LC_CTYPE=3Dde_DE.UTF-8 (charmap=3DUTF-8)
Shell: /bin/sh linked to /bin/dash

Versions of packages linux-image-3.10-2-686-pae depends on:
ii  debconf [debconf-2.0]                   1.5.50
ii  initramfs-tools [linux-initramfs-tool]  0.113
ii  kmod                                    9-3
ii  linux-base                              3.5
ii  module-init-tools                       9-3

Versions of packages linux-image-3.10-2-686-pae recommends:
ii  firmware-linux-free  3.2
ii  libc6-i686           2.17-92

Versions of packages linux-image-3.10-2-686-pae suggests:
pn  debian-kernel-handbook  <none>
ii  grub-pc                 2.00-17
pn  linux-doc-3.10          <none>

Versions of packages linux-image-3.10-2-686-pae is related to:
pn  firmware-atheros        <none>
pn  firmware-bnx2           <none>
pn  firmware-bnx2x          <none>
pn  firmware-brcm80211      <none>
pn  firmware-intelwimax     <none>
pn  firmware-ipw2x00        <none>
pn  firmware-ivtv           <none>
pn  firmware-iwlwifi        <none>
pn  firmware-libertas       <none>
pn  firmware-linux          <none>
pn  firmware-linux-nonfree  <none>
pn  firmware-myricom        <none>
pn  firmware-netxen         <none>
pn  firmware-qlogic         <none>
pn  firmware-ralink         <none>
pn  firmware-realtek        <none>
pn  xen-hypervisor          <none>

-- debconf information excluded

--=-qSOJ4KreIo3eDExSLPeX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iEYEABECAAYFAlJQIa0ACgkQPX1aK2wOHVgS4wCfabmNaAd/pZXzNvm8sQb3YF2s
0KsAnjntoGb8wPYu1aeANA/6ltGk1RkA
=l3E7
-----END PGP SIGNATURE-----

--=-qSOJ4KreIo3eDExSLPeX--
