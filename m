From: Victor Rosales <todoesverso@gmail.com>
Subject: PROBLEM: Wireless get disconnected and systems gets temporarily non responsive
Date: Thu, 4 Oct 2012 12:26:37 -0300
Message-ID: <CADZN+F5jchJh69=5X-Fi5MwgUH_HFGiTH4EJK0ZSCh5BWeDm=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0021cc0229c6e12bd004cb3d627e
To: Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:56529 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965609Ab2JDP1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 11:27:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0021cc0229c6e12bd004cb3d627e
Content-Type: text/plain; charset=ISO-8859-1

[1.] Wireless get disconnected and systems gets temporarily non responsive
[2.] I successfully connect from my "lenovo T400" to a wireless
network with TSL authentication
      using certificates and the after a while I start seeing dmesg
errors, the whole systems gets
      unresponsive for a few seconds and the wireless disconnects and
re connects.
[3.] modules, networking, kernel, wireless, iwlwifi
[4.] Kernel information
[4.1.] Linux version 3.6.0-vhrosale (root@vhrosale-debian) (gcc
version 4.7.1 (Debian 4.7.1-7) ) #1 SMP Thu Oct 4 11:10:43 ART 2012
[4.2.] <attached>
[5.] -
[6.] -
[7.] -
[8.] Environment
[8.1.]
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux vhrosale-debian 3.6.0-vhrosale #1 SMP Thu Oct 4 11:10:43 ART
2012 x86_64 GNU/Linux

Gnu C                  4.7
Gnu make               3.81
binutils               2.22
util-linux             scripts/ver_linux: 23: scripts/ver_linux:
fdformat: not found
mount                  support
module-init-tools      found
Linux C Library        2.13
Dynamic linker (ldd)   2.13
Procps                 3.3.3
Kbd                    1.15.3
Sh-utils               8.13
Modules Loaded         ip6table_filter ip6_tables iptable_filter
ip_tables ebtable_nat ebtables x_tables ppdev lp bnep rfcomm
binfmt_misc uinput nfsd auth_rpcgss nfs_acl nfs lockd fscache sunrpc
loop firewire_sbp2 joydev arc4 iwldvm pcmcia mac80211 iTCO_wdt
iTCO_vendor_support coretemp kvm_intel hid_generic btusb bluetooth kvm
yenta_socket pcmcia_rsrc psmouse pcmcia_core serio_raw pcspkr evdev
i915 lpc_ich mfd_core drm_kms_helper ac i2c_i801 thinkpad_acpi
parport_pc parport nvram drm battery tpm_tis tpm tpm_bios video
snd_hda_codec_conexant i2c_algo_bit i2c_core iwlwifi snd_hda_intel
snd_hda_codec cfg80211 snd_hwdep snd_pcm snd_page_alloc snd_timer snd
acpi_cpufreq rfkill soundcore button wmi mperf processor ext4 crc16
jbd2 mbcache sha256_generic ablk_helper cryptd aes_x86_64 aes_generic
cbc usbhid hid dm_crypt dm_mod sg sr_mod sd_mod cdrom crc_t10dif
microcode ahci libahci libata firewire_ohci firewire_core crc_itu_t
scsi_mod thermal thermal_sys uhci_hcd ehci_hcd e1000e usbcore
usb_common

[8.2.]
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 23
model name	: Intel(R) Core(TM)2 Duo CPU     T9400  @ 2.53GHz
stepping	: 6
microcode	: 0x60f
cpu MHz		: 800.000
cache size	: 6144 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 2
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
lm constant_tsc arch_perfmon pebs bts nopl aperfmperf pni dtes64
monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm
dtherm tpr_shadow vnmi flexpriority
bogomips	: 5054.40
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 23
model name	: Intel(R) Core(TM)2 Duo CPU     T9400  @ 2.53GHz
stepping	: 6
microcode	: 0x60f
cpu MHz		: 800.000
cache size	: 6144 KB
physical id	: 0
siblings	: 2
core id		: 1
cpu cores	: 2
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
lm constant_tsc arch_perfmon pebs bts nopl aperfmperf pni dtes64
monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm
dtherm tpr_shadow vnmi flexpriority
bogomips	: 5054.40
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

[8.3.]
ip6table_filter 12540 0 - Live 0xffffffffa0649000
ip6_tables 22092 1 ip6table_filter, Live 0xffffffffa063e000
iptable_filter 12536 0 - Live 0xffffffffa0639000
ip_tables 21997 1 iptable_filter, Live 0xffffffffa062e000
ebtable_nat 12580 0 - Live 0xffffffffa05a4000
ebtables 26254 1 ebtable_nat, Live 0xffffffffa05aa000
x_tables 18996 5
ip6table_filter,ip6_tables,iptable_filter,ip_tables,ebtables, Live
0xffffffffa059e000
ppdev 12763 0 - Live 0xffffffffa0510000
lp 17160 0 - Live 0xffffffffa0598000
bnep 17574 2 - Live 0xffffffffa0516000
rfcomm 33695 0 - Live 0xffffffffa0506000
binfmt_misc 12957 1 - Live 0xffffffffa0485000
uinput 17537 1 - Live 0xffffffffa0450000
nfsd 198934 2 - Live 0xffffffffa05fc000
auth_rpcgss 29433 1 nfsd, Live 0xffffffffa04fd000
nfs_acl 12511 1 nfsd, Live 0xffffffffa0409000
nfs 105744 0 - Live 0xffffffffa05e1000
lockd 55491 2 nfsd,nfs, Live 0xffffffffa0458000
fscache 37000 1 nfs, Live 0xffffffffa03fe000
sunrpc 160131 6 nfsd,auth_rpcgss,nfs_acl,nfs,lockd, Live 0xffffffffa05b8000
loop 22960 0 - Live 0xffffffffa03f7000
firewire_sbp2 17956 0 - Live 0xffffffffa0377000
joydev 17318 0 - Live 0xffffffffa0371000
arc4 12543 2 - Live 0xffffffffa043d000
iwldvm 111689 0 - Live 0xffffffffa0491000
pcmcia 32726 0 - Live 0xffffffffa0447000
mac80211 344068 1 iwldvm, Live 0xffffffffa0542000
iTCO_wdt 12831 0 - Live 0xffffffffa035b000
iTCO_vendor_support 12704 1 iTCO_wdt, Live 0xffffffffa0442000
coretemp 12854 0 - Live 0xffffffffa048c000
kvm_intel 118198 0 - Live 0xffffffffa0467000
hid_generic 12385 0 - Live 0xffffffffa041f000
btusb 17553 0 - Live 0xffffffffa05b2000
bluetooth 150008 11 bnep,rfcomm,btusb, Live 0xffffffffa051c000
kvm 304634 1 kvm_intel, Live 0xffffffffa04b1000
yenta_socket 22908 0 - Live 0xffffffffa0436000
pcmcia_rsrc 17533 1 yenta_socket, Live 0xffffffffa0336000
psmouse 69148 0 - Live 0xffffffffa0424000
pcmcia_core 18373 3 pcmcia,yenta_socket,pcmcia_rsrc, Live 0xffffffffa0419000
serio_raw 12940 0 - Live 0xffffffffa0414000
pcspkr 12632 0 - Live 0xffffffffa040f000
evdev 17612 25 - Live 0xffffffffa0330000
i915 421644 4 - Live 0xffffffffa038b000
lpc_ich 16757 0 - Live 0xffffffffa032a000
mfd_core 12601 1 lpc_ich, Live 0xffffffffa0325000
drm_kms_helper 27235 1 i915, Live 0xffffffffa0383000
ac 12624 0 - Live 0xffffffffa037e000
i2c_i801 17045 0 - Live 0xffffffffa02c2000
thinkpad_acpi 61289 0 - Live 0xffffffffa0361000
parport_pc 22409 1 - Live 0xffffffffa0354000
parport 31901 3 ppdev,lp,parport_pc, Live 0xffffffffa034b000
nvram 13092 1 thinkpad_acpi, Live 0xffffffffa0342000
drm 197759 5 i915,drm_kms_helper, Live 0xffffffffa02e9000
battery 13109 0 - Live 0xffffffffa033d000
tpm_tis 17275 1 - Live 0xffffffffa031b000
tpm 17937 1 tpm_tis, Live 0xffffffffa02df000
tpm_bios 12948 1 tpm, Live 0xffffffffa028e000
video 17631 1 i915, Live 0xffffffffa02d9000
snd_hda_codec_conexant 45482 1 - Live 0xffffffffa02ac000
i2c_algo_bit 12841 1 i915, Live 0xffffffffa0245000
i2c_core 24041 5 i915,drm_kms_helper,i2c_i801,drm,i2c_algo_bit, Live
0xffffffffa0287000
iwlwifi 64047 1 iwldvm, Live 0xffffffffa02c8000
snd_hda_intel 26499 3 - Live 0xffffffffa02ba000
snd_hda_codec 83791 2 snd_hda_codec_conexant,snd_hda_intel, Live
0xffffffffa0296000
cfg80211 143809 3 iwldvm,mac80211,iwlwifi, Live 0xffffffffa0262000
snd_hwdep 13189 1 snd_hda_codec, Live 0xffffffffa019d000
snd_pcm 64168 2 snd_hda_intel,snd_hda_codec, Live 0xffffffffa0251000
snd_page_alloc 12969 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0240000
snd_timer 22812 1 snd_pcm, Live 0xffffffffa024a000
snd 53038 13 thinkpad_acpi,snd_hda_codec_conexant,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_timer,
Live 0xffffffffa0232000
acpi_cpufreq 12972 1 - Live 0xffffffffa020c000
rfkill 19018 5 bluetooth,thinkpad_acpi,cfg80211, Live 0xffffffffa0223000
soundcore 13026 1 snd, Live 0xffffffffa022d000
button 12937 1 i915, Live 0xffffffffa021e000
wmi 13243 0 - Live 0xffffffffa0215000
mperf 12453 1 acpi_cpufreq, Live 0xffffffffa01a3000
processor 28408 3 acpi_cpufreq, Live 0xffffffffa0195000
ext4 366770 3 - Live 0xffffffffa01b1000
crc16 12343 2 bluetooth,ext4, Live 0xffffffffa0173000
jbd2 71862 1 ext4, Live 0xffffffffa0182000
mbcache 13065 1 ext4, Live 0xffffffffa016e000
sha256_generic 16797 4 - Live 0xffffffffa017c000
ablk_helper 12572 0 - Live 0xffffffffa0169000
cryptd 14560 1 ablk_helper, Live 0xffffffffa0160000
aes_x86_64 16796 4 - Live 0xffffffffa0145000
aes_generic 33026 1 aes_x86_64, Live 0xffffffffa0156000
cbc 12696 2 - Live 0xffffffffa00a5000
usbhid 40753 0 - Live 0xffffffffa014b000
hid 81572 2 hid_generic,usbhid, Live 0xffffffffa0130000
dm_crypt 18420 2 - Live 0xffffffffa00d6000
dm_mod 63898 5 dm_crypt, Live 0xffffffffa011f000
sg 26095 0 - Live 0xffffffffa0117000
sr_mod 21945 0 - Live 0xffffffffa0110000
sd_mod 36205 5 - Live 0xffffffffa0106000
cdrom 35212 1 sr_mod, Live 0xffffffffa008f000
crc_t10dif 12348 1 sd_mod, Live 0xffffffffa0068000
microcode 13657 0 - Live 0xffffffffa001e000
ahci 25060 4 - Live 0xffffffffa00aa000
libahci 22867 1 ahci, Live 0xffffffffa0012000
libata 141380 2 ahci,libahci, Live 0xffffffffa00b2000
firewire_ohci 31931 0 - Live 0xffffffffa0005000
firewire_core 49141 2 firewire_sbp2,firewire_ohci, Live 0xffffffffa005b000
crc_itu_t 12347 1 firewire_core, Live 0xffffffffa0019000
scsi_mod 162682 5 firewire_sbp2,sg,sr_mod,sd_mod,libata, Live 0xffffffffa00dd000
thermal 17383 0 - Live 0xffffffffa0030000
thermal_sys 18229 3 video,processor,thermal, Live 0xffffffffa0026000
uhci_hcd 26976 0 - Live 0xffffffffa01a9000
ehci_hcd 40531 0 - Live 0xffffffffa009a000
e1000e 134602 0 - Live 0xffffffffa006d000
usbcore 129466 4 btusb,usbhid,uhci_hcd,ehci_hcd, Live 0xffffffffa003a000
usb_common 12354 1 usbcore, Live 0xffffffffa0000000

[8.4.]
~/kernels/linux-3.6$ cat /proc/ioports
0000-0cf7 : PCI Bus 0000:00
  0000-001f : dma1
  0020-0021 : pic1
  0040-0043 : timer0
  0050-0053 : timer1
  0060-0060 : keyboard
  0062-0062 : EC data
  0064-0064 : keyboard
  0066-0066 : EC cmd
  0070-0071 : rtc0
  0080-008f : dma page reg
  00a0-00a1 : pic2
  00c0-00df : dma2
  00f0-00ff : fpu
  03bc-03be : parport0
  03c0-03df : vga+
  03f8-03ff : serial
  0800-080f : pnp 00:02
0cf8-0cff : PCI conf1
0d00-ffff : PCI Bus 0000:00
  1000-107f : pnp 00:02
    1000-1003 : ACPI PM1a_EVT_BLK
    1004-1005 : ACPI PM1a_CNT_BLK
    1008-100b : ACPI PM_TMR
    1010-1015 : ACPI CPU throttle
    1020-102f : ACPI GPE0_BLK
    1030-1033 : iTCO_wdt
      1030-1033 : iTCO_wdt
    1050-1050 : ACPI PM2_CNT_BLK
    1060-107f : iTCO_wdt
      1060-107f : iTCO_wdt
  1180-11ff : pnp 00:02
  15e0-15ef : pnp 00:02
  1600-167f : pnp 00:02
  1680-169f : pnp 00:02
  1800-1807 : 0000:00:02.0
  1838-183b : 0000:00:1f.2
    1838-183b : ahci
  183c-183f : 0000:00:1f.2
    183c-183f : ahci
  1840-185f : 0000:00:19.0
  1860-187f : 0000:00:1a.0
    1860-187f : uhci_hcd
  1880-189f : 0000:00:1a.1
    1880-189f : uhci_hcd
  18a0-18bf : 0000:00:1a.2
    18a0-18bf : uhci_hcd
  18c0-18df : 0000:00:1d.0
    18c0-18df : uhci_hcd
  18e0-18ff : 0000:00:1d.1
    18e0-18ff : uhci_hcd
  1c00-1c1f : 0000:00:1d.2
    1c00-1c1f : uhci_hcd
  1c20-1c3f : 0000:00:1f.2
    1c20-1c3f : ahci
  1c40-1c47 : 0000:00:1f.2
    1c40-1c47 : ahci
  1c48-1c4f : 0000:00:1f.2
    1c48-1c4f : ahci
  1c60-1c7f : 0000:00:1f.3
    1c60-1c7f : i801_smbus
  2000-2fff : PCI Bus 0000:04
    2000-20ff : 0000:04:00.0
  3000-3fff : PCI Bus 0000:05
  4000-4fff : PCI Bus 0000:0d
  5000-8fff : PCI Bus 0000:15
    5000-50ff : PCI CardBus 0000:16
    5400-54ff : PCI CardBus 0000:16
  9000-9fff : PCI Bus 0000:02
  a000-afff : PCI Bus 0000:03

~/kernels/linux-3.6$ cat /proc/iomem
00000000-0000ffff : reserved
00010000-0009abff : System RAM
0009ac00-0009ffff : reserved
000a0000-000bffff : PCI Bus 0000:00
000c0000-000c7fff : Video ROM
000c8000-000cbfff : pnp 00:00
000cc000-000cffff : pnp 00:00
000d0000-000d0fff : Adapter ROM
000d1000-000d1fff : Adapter ROM
000d2000-000d2fff : Adapter ROM
000d3000-000d53ff : Adapter ROM
000d6000-000d7fff : reserved
000d8000-000dbfff : PCI Bus 0000:00
000dc000-000fffff : reserved
  000e0000-000effff : Extension ROM
  000f0000-000fffff : System ROM
00100000-bd4a0fff : System RAM
  01000000-0134b6ac : Kernel code
  0134b6ad-0168723f : Kernel data
  01717000-017e9fff : Kernel bss
bd4a1000-bd4a6fff : reserved
bd4a7000-bd5b6fff : System RAM
bd5b7000-bd60efff : reserved
bd60f000-bd6c5fff : System RAM
bd6c6000-bd6d0fff : ACPI Non-volatile Storage
bd6d1000-bd6d3fff : ACPI Tables
bd6d4000-bd6d7fff : reserved
bd6d8000-bd6dbfff : ACPI Non-volatile Storage
bd6dc000-bd6defff : reserved
bd6df000-bd705fff : ACPI Non-volatile Storage
bd706000-bd707fff : ACPI Tables
bd708000-bd90efff : reserved
bd90f000-bd99efff : ACPI Non-volatile Storage
bd99f000-bd9fefff : ACPI Tables
bd9ff000-bd9fffff : System RAM
bda00000-bdbfffff : RAM buffer
bdc00000-bfffffff : reserved
c0000000-febfffff : PCI Bus 0000:00
  c0000000-c01fffff : PCI Bus 0000:02
  c0200000-c03fffff : PCI Bus 0000:02
  c0400000-c05fffff : PCI Bus 0000:03
  c0600000-c08fffff : PCI Bus 0000:04
    c0600000-c060ffff : 0000:04:00.0
  c0900000-c0900fff : Intel Flush Page
  c4000000-c7ffffff : PCI CardBus 0000:16
  d0000000-dfffffff : 0000:00:02.0
  e0000000-efffffff : reserved
    e0000000-efffffff : pnp 00:02
      e0000000-e3ffffff : PCI MMCONFIG 0000 [bus 00-3f]
  f0000000-f3ffffff : PCI Bus 0000:15
    f0000000-f3ffffff : PCI CardBus 0000:16
  f4000000-f40fffff : PCI Bus 0000:05
  f4100000-f41fffff : PCI Bus 0000:0d
  f4200000-f42fffff : 0000:00:02.1
  f4300000-f43fffff : PCI Bus 0000:03
    f4300000-f4301fff : 0000:03:00.0
      f4300000-f4301fff : iwlwifi
  f4400000-f47fffff : 0000:00:02.0
  f4800000-f7ffffff : PCI Bus 0000:15
    f4800000-f4800fff : 0000:15:00.0
      f4800000-f4800fff : yenta_socket
    f4801000-f48017ff : 0000:15:00.1
      f4801000-f48017ff : firewire_ohci
  f8000000-f9ffffff : PCI Bus 0000:05
  fa000000-fbffffff : PCI Bus 0000:0d
  fc000000-fc0fffff : PCI Bus 0000:04
    fc000000-fc0003ff : 0000:04:00.0
  fc100000-fc11ffff : 0000:00:19.0
    fc100000-fc11ffff : e1000e
  fc320000-fc323fff : 0000:00:1b.0
    fc320000-fc323fff : ICH HD audio
  fc325000-fc325fff : 0000:00:19.0
    fc325000-fc325fff : e1000e
  fc326000-fc3267ff : 0000:00:1f.2
    fc326000-fc3267ff : ahci
  fc326800-fc32680f : 0000:00:03.0
  fc326c00-fc326fff : 0000:00:1a.7
    fc326c00-fc326fff : ehci_hcd
  fc327000-fc3273ff : 0000:00:1d.7
    fc327000-fc3273ff : ehci_hcd
  fc327400-fc3274ff : 0000:00:1f.3
  feb00000-feb00fff : dmar2
  feb01000-feb01fff : dmar1
  feb02000-feb02fff : dmar3
  feb03000-feb03fff : dmar0
fec00000-fec0ffff : reserved
  fec00000-fec003ff : IOAPIC 0
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : reserved
fed10000-fed13fff : reserved
  fed10000-fed13fff : pnp 00:02
fed18000-fed19fff : reserved
  fed18000-fed18fff : pnp 00:02
  fed19000-fed19fff : pnp 00:02
fed1c000-fed8ffff : reserved
  fed1c000-fed1ffff : pnp 00:02
    fed1f410-fed1f414 : iTCO_wdt
      fed1f410-fed1f414 : iTCO_wdt
  fed45000-fed4bfff : pnp 00:02
fee00000-fee00fff : Local APIC
  fee00000-fee00fff : reserved
ff800000-ffffffff : reserved
100000000-13bffffff : System RAM


[8.5.]
lspci -vvv
00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory
Controller Hub (rev 07)
	Subsystem: Lenovo Device 20e0
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0a <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Mobile 4 Series
Chipset Integrated Graphics Controller (rev 07) (prog-if 00 [VGA
controller])
	Subsystem: Lenovo Device 20e4
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 49
	Region 0: Memory at f4400000 (64-bit, non-prefetchable) [size=4M]
	Region 2: Memory at d0000000 (64-bit, prefetchable) [size=256M]
	Region 4: I/O ports at 1800 [size=8]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4192
	Capabilities: [d0] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: i915

00:02.1 Display controller: Intel Corporation Mobile 4 Series Chipset
Integrated Graphics Controller (rev 07)
	Subsystem: Lenovo Device 20e4
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Region 0: Memory at f4200000 (64-bit, non-prefetchable) [size=1M]
	Capabilities: [d0] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-

00:03.0 Communication controller: Intel Corporation Mobile 4 Series
Chipset MEI Controller (rev 07)
	Subsystem: Lenovo Device 20e6
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at fc326800 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000

00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network
Connection (rev 03)
	Subsystem: Lenovo Device 20ee
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at fc100000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at fc325000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 1840 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME+
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41c2
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e

00:1a.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #4 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 20
	Region 4: I/O ports at 1860 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #5 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 21
	Region 4: I/O ports at 1880 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #6 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 22
	Region 4: I/O ports at 18a0 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1a.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #2 (rev 03) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 20f1
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 23
	Region 0: Memory at fc326c00 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME+
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd

00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio
Controller (rev 03)
	Subsystem: Lenovo Device 20f2
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 47
	Region 0: Memory at fc320000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4172
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0
<64ns, L1 <1us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
		VC1:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable- ID=0 ArbSelect=Fixed TC/VC=00
			Status:	NegoPending- InProgress-
	Capabilities: [130 v1] Root Complex Link
		Desc:	PortNumber=0f ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 1 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: c0000000-c01fffff
	Prefetchable memory behind bridge: 00000000c0200000-00000000c03fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #0, PowerLimit 6.500W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ HPIrq+ LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41c1
	Capabilities: [90] Subsystem: Lenovo Device 20f3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=01 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: pcieport

00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 2 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: f4300000-f43fffff
	Prefetchable memory behind bridge: 00000000c0400000-00000000c05fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #1, PowerLimit 6.500W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ HPIrq+ LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41d1
	Capabilities: [90] Subsystem: Lenovo Device 20f3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=02 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: pcieport

00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 3 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: fc000000-fc0fffff
	Prefetchable memory behind bridge: 00000000c0600000-00000000c08fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<256ns, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #2, PowerLimit 6.500W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ HPIrq+ LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 41e1
	Capabilities: [90] Subsystem: Lenovo Device 20f3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=03 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: pcieport

00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 4 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=0c, sec-latency=0
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f8000000-f9ffffff
	Prefetchable memory behind bridge: 00000000f4000000-00000000f40fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #3, PowerLimit 6.500W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ HPIrq+ LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4122
	Capabilities: [90] Subsystem: Lenovo Device 20f3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=04 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: pcieport

00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express
Port 5 (rev 03) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=0d, subordinate=14, sec-latency=0
	I/O behind bridge: 00004000-00004fff
	Memory behind bridge: fa000000-fbffffff
	Prefetchable memory behind bridge: 00000000f4100000-00000000f41fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<1us, L1 <4us
			ClockPM- Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
			Slot #4, PowerLimit 6.500W; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ HPIrq+ LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4142
	Capabilities: [90] Subsystem: Lenovo Device 20f3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed+ WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=01
			Status:	NegoPending- InProgress-
	Capabilities: [180 v1] Root Complex Link
		Desc:	PortNumber=05 ComponentID=02 EltType=Config
		Link0:	Desc:	TargetPort=00 TargetComponent=02 AssocRCRB-
LinkType=MemMapped LinkValid+
			Addr:	00000000fed1c000
	Kernel driver in use: pcieport

00:1d.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #1 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at 18c0 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #2 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 17
	Region 4: I/O ports at 18e0 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB
UHCI Controller #3 (rev 03) (prog-if 00 [UHCI])
	Subsystem: Lenovo Device 20f0
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 1c00 [size=32]
	Capabilities: [50] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
EHCI Controller #1 (rev 03) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 20f1
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at fc327000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Capabilities: [98] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ehci_hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)
(prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=15, subordinate=18, sec-latency=32
	I/O behind bridge: 00005000-00008fff
	Memory behind bridge: f4800000-f7ffffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f3ffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Lenovo Device 20f4

00:1f.0 ISA bridge: Intel Corporation ICH9M-E LPC Interface Controller (rev 03)
	Subsystem: Lenovo Device 20f5
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information: Len=0c <?>
	Kernel driver in use: lpc_ich

00:1f.2 SATA controller: Intel Corporation 82801IBM/IEM
(ICH9M/ICH9M-E) 4 port SATA Controller [AHCI mode] (rev 03) (prog-if
01 [AHCI 1.0])
	Subsystem: Lenovo Device 20f8
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 46
	Region 0: I/O ports at 1c48 [size=8]
	Region 1: I/O ports at 183c [size=4]
	Region 2: I/O ports at 1c40 [size=8]
	Region 3: I/O ports at 1838 [size=4]
	Region 4: I/O ports at 1c20 [size=32]
	Region 5: Memory at fc326000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] MSI: Enable+ Count=1/16 Maskable- 64bit-
		Address: fee0300c  Data: 4162
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
	Capabilities: [b0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 03)
	Subsystem: Lenovo Device 20f9
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at fc327400 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 1c60 [size=32]
	Kernel driver in use: i801_smbus

03:00.0 Network controller: Intel Corporation Ultimate N WiFi Link 5300
	Subsystem: Intel Corporation Device 1011
	Physical Slot: 1
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 48
	Region 0: Memory at f4300000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [c8] Power Management version 3
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4182
	Capabilities: [e0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<128ns, L1 <32us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
	Capabilities: [140 v1] Device Serial Number 00-21-6a-ff-ff-0c-c5-16
	Kernel driver in use: iwlwifi

04:00.0 Memory controller: Intel Corporation Turbo Memory Controller (rev 11)
	Subsystem: Intel Corporation Device 444b
	Physical Slot: 2
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at fc000000 (32-bit, non-prefetchable) [size=1K]
	Region 2: I/O ports at 2000 [size=256]
	[virtual] Expansion ROM at c0600000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [68] Express (v1) Legacy Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0
<512ns, L1 <32us
			ClockPM- Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-

15:00.0 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev ba)
	Subsystem: Lenovo Device 20c6
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 168, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f4800000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=15, secondary=16, subordinate=17, sec-latency=176
	Memory window 0: f0000000-f3ffffff (prefetchable)
	Memory window 1: c4000000-c7ffffff
	I/O window 0: 00005000-000050ff
	I/O window 1: 00005400-000054ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
	16-bit legacy interface ports at 0001
	Kernel driver in use: yenta_cardbus

15:00.1 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller
(rev 04) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 20c7
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (500ns min, 1000ns max), Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f4801000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME+
	Kernel driver in use: firewire_ohci


[8.6.] -

[8.7.] dmesg output

[   59.338822] wlan0: authenticate with 00:24:6c:29:52:e9
[   59.342538] wlan0: send auth to 00:24:6c:29:52:e9 (try 1/3)
[   59.543054] wlan0: send auth to 00:24:6c:29:52:e9 (try 2/3)
[   59.543611] wlan0: authenticated
[   59.543927] wlan0: waiting for beacon from 00:24:6c:29:52:e9
[   59.581052] wlan0: associate with 00:24:6c:29:52:e9 (try 1/3)
[   59.586441] wlan0: RX AssocResp from 00:24:6c:29:52:e9 (capab=0x511
status=0 aid=1)
[   59.589727] wlan0: associated
[   59.589783] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   59.589930] cfg80211: Calling CRDA for country: US
[   59.600992] cfg80211: Regulatory domain changed to country: US
[   59.600999] cfg80211:   (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp)
[   59.601031] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz),
(300 mBi, 2700 mBm)
[   59.601038] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz),
(300 mBi, 1700 mBm)
[   59.601043] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   59.601049] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   59.601066] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz),
(300 mBi, 2000 mBm)
[   59.601078] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz),
(300 mBi, 3000 mBm)
[   74.285977] ACPI: \_SB_.GDCK - undocking
[   74.308093] usb 1-5: USB disconnect, device number 4
[   74.308096] usb 1-5.1: USB disconnect, device number 5
[   74.308098] usb 1-5.1.1: USB disconnect, device number 7
[   74.359859] usb 1-5.2: USB disconnect, device number 6
[   76.197260] e1000e: eth0 NIC Link is Down
[   77.072402] Monitor-Mwait will be used to enter C-3 state
[   77.072750] thinkpad_acpi: EC reports that Thermal Table has changed
[  307.708214] iwlwifi 0000:03:00.0: fail to flush all tx fifo queues
[  309.708290] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  309.708304] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 85
[  309.708313] wlan0: HW problem - can not stop rx aggregation for tid 0
[  311.708271] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  311.708284] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 88
[  311.708293] wlan0: HW problem - can not stop rx aggregation for tid 2
[  313.708282] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  313.708295] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 91
[  313.708304] wlan0: HW problem - can not stop rx aggregation for tid 5
[  315.708278] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  315.708291] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 94
[  315.708299] wlan0: HW problem - can not stop rx aggregation for tid 6
[  317.708313] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  317.708326] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 97
[  317.708337] wlan0: failed to remove key (0, 00:24:6c:29:52:e9) from
hardware (-110)
[  319.709149] iwlwifi 0000:03:00.0: Error sending REPLY_QOS_PARAM:
time out after 2000ms.
[  319.709163] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 100
[  319.709171] iwlwifi 0000:03:00.0: Failed to update QoS
[  321.709322] iwlwifi 0000:03:00.0: Error sending REPLY_RXON: time
out after 2000ms.
[  321.709336] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 103
[  321.709344] iwlwifi 0000:03:00.0: Error clearing ASSOC_MSK on BSS (-110)
[  323.709313] iwlwifi 0000:03:00.0: Error sending REPLY_RXON: time
out after 2000ms.
[  323.709327] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 106
[  323.709336] iwlwifi 0000:03:00.0: Error clearing ASSOC_MSK on BSS (-110)
[  325.706096] iwlwifi 0000:03:00.0: No space in command queue
[  325.706110] iwlwifi 0000:03:00.0: Restarting adapter queue is full
[  325.706131] iwlwifi 0000:03:00.0: Error sending REPLY_LEDS_CMD:
enqueue_hcmd failed: -28
[  325.710322] iwlwifi 0000:03:00.0: Error sending REPLY_ADD_STA: time
out after 2000ms.
[  325.710336] iwlwifi 0000:03:00.0: Current CMD queue read_ptr 79 write_ptr 108
[  325.710355] wlan0: failed to remove key (1, ff:ff:ff:ff:ff:ff) from
hardware (-110)
[  325.710538] cfg80211: Calling CRDA to update world regulatory domain
[  327.712257] iwlwifi 0000:03:00.0: fail to flush all tx fifo queues
[  327.713294] ------------[ cut here ]------------
[  327.713294] WARNING: at drivers/net/wireless/iwlwifi/iwl-io.c:150
iwl_grab_nic_access+0x45/0x52 [iwlwifi]()
[  327.713294] Hardware name: 6475BY5
[  327.713294] Timeout waiting for hardware access (CSR_GP_CNTRL 0x080403d8)
[  327.713294] Modules linked in: ip6table_filter ip6_tables
iptable_filter ip_tables ebtable_nat ebtables x_tables ppdev lp bnep
rfcomm binfmt_misc uinput nfsd auth_rpcgss nfs_acl nfs lockd fscache
sunrpc loop firewire_sbp2 joydev arc4 iwldvm pcmcia mac80211 iTCO_wdt
iTCO_vendor_support coretemp kvm_intel hid_generic btusb bluetooth kvm
yenta_socket pcmcia_rsrc psmouse pcmcia_core serio_raw pcspkr evdev
i915 lpc_ich mfd_core drm_kms_helper ac i2c_i801 thinkpad_acpi
parport_pc parport nvram drm battery tpm_tis tpm tpm_bios video
snd_hda_codec_conexant i2c_algo_bit i2c_core iwlwifi snd_hda_intel
snd_hda_codec cfg80211 snd_hwdep snd_pcm snd_page_alloc snd_timer snd
acpi_cpufreq rfkill soundcore button wmi mperf processor ext4 crc16
jbd2 mbcache sha256_generic ablk_helper cryptd aes_x86_64 aes_generic
cbc usbhid hid dm_crypt dm_mod sg sr_mod sd_mod cdrom crc_t10dif
microcode ahci libahci libata firewire_ohci firewire_core crc_itu_t
scsi_mod thermal thermal_sys uhci_hcd ehci_hcd e1000e usbcore
usb_common
[  327.713294] Pid: 192, comm: kworker/u:3 Not tainted 3.6.0-vhrosale #1
[  327.713294] Call Trace:
[  327.713294]  [<ffffffff81031a5b>] ? warn_slowpath_common+0x76/0x8a
[  327.713294]  [<ffffffff81031b07>] ? warn_slowpath_fmt+0x45/0x4a
[  327.713294]  [<ffffffffa02c8204>] ? iwl_grab_nic_access+0x45/0x52 [iwlwifi]
[  327.713294]  [<ffffffffa02c849f>] ? iwl_write_prph+0x24/0x51 [iwlwifi]
[  327.713294]  [<ffffffff813477fb>] ? _raw_spin_lock_irqsave+0x14/0x34
[  327.713294]  [<ffffffffa02cdd91>] ?
iwl_trans_pcie_stop_device+0x73/0x202 [iwlwifi]
[  327.713294]  [<ffffffffa0492e5d>] ? iwl_down+0x139/0x193 [iwldvm]
[  327.713294]  [<ffffffffa0492ef4>] ? iwlagn_prepare_restart+0x3d/0x9e [iwldvm]
[  327.713294]  [<ffffffffa0493084>] ? iwl_bg_restart+0x3c/0x24f [iwldvm]
[  327.713294]  [<ffffffff8104800c>] ? process_one_work+0x169/0x2d8
[  327.713294]  [<ffffffffa0493048>] ?
iwl_cancel_deferred_work+0x71/0x71 [iwldvm]
[  327.713294]  [<ffffffff810484eb>] ? worker_thread+0x1cd/0x270
[  327.713294]  [<ffffffff8104831e>] ? rescuer_thread+0x17e/0x17e
[  327.713294]  [<ffffffff8104831e>] ? rescuer_thread+0x17e/0x17e
[  327.713294]  [<ffffffff8104b81e>] ? kthread+0x67/0x6f
[  327.713294]  [<ffffffff813491c4>] ? kernel_thread_helper+0x4/0x10
[  327.713294]  [<ffffffff8104b7b7>] ? kthread_freezable_should_stop+0x3c/0x3c
[  327.713294]  [<ffffffff813491c0>] ? gs_change+0x13/0x13
[  327.713294] ---[ end trace db55bbd3855157a7 ]---


[X.] Other notes, patches, fixes, workarounds:


-- 
PS1='todoesverso> '
- http://gnuguitarinux.sourceforge.net/

--0021cc0229c6e12bd004cb3d627e
Content-Type: application/octet-stream; name=config
Content-Disposition: attachment; filename=config
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h7w0jved0

Q09ORklHXzY0QklUPXkKQ09ORklHX1g4Nl82ND15CkNPTkZJR19YODY9eQpDT05GSUdfSU5TVFJV
Q1RJT05fREVDT0RFUj15CkNPTkZJR19PVVRQVVRfRk9STUFUPSJlbGY2NC14ODYtNjQiCkNPTkZJ
R19BUkNIX0RFRkNPTkZJRz0iYXJjaC94ODYvY29uZmlncy94ODZfNjRfZGVmY29uZmlnIgpDT05G
SUdfTE9DS0RFUF9TVVBQT1JUPXkKQ09ORklHX1NUQUNLVFJBQ0VfU1VQUE9SVD15CkNPTkZJR19I
QVZFX0xBVEVOQ1lUT1BfU1VQUE9SVD15CkNPTkZJR19NTVU9eQpDT05GSUdfTkVFRF9ETUFfTUFQ
X1NUQVRFPXkKQ09ORklHX05FRURfU0dfRE1BX0xFTkdUSD15CkNPTkZJR19HRU5FUklDX0lTQV9E
TUE9eQpDT05GSUdfR0VORVJJQ19CVUc9eQpDT05GSUdfR0VORVJJQ19CVUdfUkVMQVRJVkVfUE9J
TlRFUlM9eQpDT05GSUdfR0VORVJJQ19IV0VJR0hUPXkKQ09ORklHX0dFTkVSSUNfR1BJTz15CkNP
TkZJR19BUkNIX01BWV9IQVZFX1BDX0ZEQz15CkNPTkZJR19SV1NFTV9YQ0hHQUREX0FMR09SSVRI
TT15CkNPTkZJR19HRU5FUklDX0NBTElCUkFURV9ERUxBWT15CkNPTkZJR19BUkNIX0hBU19DUFVf
UkVMQVg9eQpDT05GSUdfQVJDSF9IQVNfREVGQVVMVF9JRExFPXkKQ09ORklHX0FSQ0hfSEFTX0NB
Q0hFX0xJTkVfU0laRT15CkNPTkZJR19BUkNIX0hBU19DUFVfQVVUT1BST0JFPXkKQ09ORklHX0hB
VkVfU0VUVVBfUEVSX0NQVV9BUkVBPXkKQ09ORklHX05FRURfUEVSX0NQVV9FTUJFRF9GSVJTVF9D
SFVOSz15CkNPTkZJR19ORUVEX1BFUl9DUFVfUEFHRV9GSVJTVF9DSFVOSz15CkNPTkZJR19BUkNI
X0hJQkVSTkFUSU9OX1BPU1NJQkxFPXkKQ09ORklHX0FSQ0hfU1VTUEVORF9QT1NTSUJMRT15CkNP
TkZJR19aT05FX0RNQTMyPXkKQ09ORklHX0FVRElUX0FSQ0g9eQpDT05GSUdfQVJDSF9TVVBQT1JU
U19PUFRJTUlaRURfSU5MSU5JTkc9eQpDT05GSUdfQVJDSF9TVVBQT1JUU19ERUJVR19QQUdFQUxM
T0M9eQpDT05GSUdfSEFWRV9JTlRFTF9UWFQ9eQpDT05GSUdfWDg2XzY0X1NNUD15CkNPTkZJR19Y
ODZfSFQ9eQpDT05GSUdfQVJDSF9IV0VJR0hUX0NGTEFHUz0iLWZjYWxsLXNhdmVkLXJkaSAtZmNh
bGwtc2F2ZWQtcnNpIC1mY2FsbC1zYXZlZC1yZHggLWZjYWxsLXNhdmVkLXJjeCAtZmNhbGwtc2F2
ZWQtcjggLWZjYWxsLXNhdmVkLXI5IC1mY2FsbC1zYXZlZC1yMTAgLWZjYWxsLXNhdmVkLXIxMSIK
Q09ORklHX0FSQ0hfQ1BVX1BST0JFX1JFTEVBU0U9eQpDT05GSUdfQVJDSF9TVVBQT1JUU19VUFJP
QkVTPXkKQ09ORklHX0RFRkNPTkZJR19MSVNUPSIvbGliL21vZHVsZXMvJFVOQU1FX1JFTEVBU0Uv
LmNvbmZpZyIKQ09ORklHX0hBVkVfSVJRX1dPUks9eQpDT05GSUdfSVJRX1dPUks9eQpDT05GSUdf
QlVJTERUSU1FX0VYVEFCTEVfU09SVD15CgpDT05GSUdfRVhQRVJJTUVOVEFMPXkKQ09ORklHX0lO
SVRfRU5WX0FSR19MSU1JVD0zMgpDT05GSUdfQ1JPU1NfQ09NUElMRT0iIgpDT05GSUdfTE9DQUxW
RVJTSU9OPSIiCkNPTkZJR19IQVZFX0tFUk5FTF9HWklQPXkKQ09ORklHX0hBVkVfS0VSTkVMX0Ja
SVAyPXkKQ09ORklHX0hBVkVfS0VSTkVMX0xaTUE9eQpDT05GSUdfSEFWRV9LRVJORUxfWFo9eQpD
T05GSUdfSEFWRV9LRVJORUxfTFpPPXkKQ09ORklHX0tFUk5FTF9HWklQPXkKQ09ORklHX0RFRkFV
TFRfSE9TVE5BTUU9Iihub25lKSIKQ09ORklHX1NXQVA9eQpDT05GSUdfU1lTVklQQz15CkNPTkZJ
R19TWVNWSVBDX1NZU0NUTD15CkNPTkZJR19QT1NJWF9NUVVFVUU9eQpDT05GSUdfUE9TSVhfTVFV
RVVFX1NZU0NUTD15CkNPTkZJR19CU0RfUFJPQ0VTU19BQ0NUPXkKQ09ORklHX0JTRF9QUk9DRVNT
X0FDQ1RfVjM9eQpDT05GSUdfRkhBTkRMRT15CkNPTkZJR19UQVNLU1RBVFM9eQpDT05GSUdfVEFT
S19ERUxBWV9BQ0NUPXkKQ09ORklHX1RBU0tfWEFDQ1Q9eQpDT05GSUdfVEFTS19JT19BQ0NPVU5U
SU5HPXkKQ09ORklHX0FVRElUPXkKQ09ORklHX0FVRElUU1lTQ0FMTD15CkNPTkZJR19BVURJVF9X
QVRDSD15CkNPTkZJR19BVURJVF9UUkVFPXkKQ09ORklHX0hBVkVfR0VORVJJQ19IQVJESVJRUz15
CgpDT05GSUdfR0VORVJJQ19IQVJESVJRUz15CkNPTkZJR19HRU5FUklDX0lSUV9QUk9CRT15CkNP
TkZJR19HRU5FUklDX0lSUV9TSE9XPXkKQ09ORklHX0dFTkVSSUNfUEVORElOR19JUlE9eQpDT05G
SUdfR0VORVJJQ19JUlFfQ0hJUD15CkNPTkZJR19JUlFfRE9NQUlOPXkKQ09ORklHX0lSUV9GT1JD
RURfVEhSRUFESU5HPXkKQ09ORklHX1NQQVJTRV9JUlE9eQpDT05GSUdfQ0xPQ0tTT1VSQ0VfV0FU
Q0hET0c9eQpDT05GSUdfQVJDSF9DTE9DS1NPVVJDRV9EQVRBPXkKQ09ORklHX0dFTkVSSUNfVElN
RV9WU1lTQ0FMTD15CkNPTkZJR19HRU5FUklDX0NMT0NLRVZFTlRTPXkKQ09ORklHX0dFTkVSSUNf
Q0xPQ0tFVkVOVFNfQlVJTEQ9eQpDT05GSUdfR0VORVJJQ19DTE9DS0VWRU5UU19CUk9BRENBU1Q9
eQpDT05GSUdfR0VORVJJQ19DTE9DS0VWRU5UU19NSU5fQURKVVNUPXkKQ09ORklHX0dFTkVSSUNf
Q01PU19VUERBVEU9eQoKQ09ORklHX1RJQ0tfT05FU0hPVD15CkNPTkZJR19OT19IWj15CkNPTkZJ
R19ISUdIX1JFU19USU1FUlM9eQoKQ09ORklHX1RSRUVfUkNVPXkKQ09ORklHX1JDVV9GQU5PVVQ9
NjQKQ09ORklHX1JDVV9GQU5PVVRfTEVBRj0xNgpDT05GSUdfUkNVX0ZBU1RfTk9fSFo9eQpDT05G
SUdfTE9HX0JVRl9TSElGVD0xNwpDT05GSUdfSEFWRV9VTlNUQUJMRV9TQ0hFRF9DTE9DSz15CkNP
TkZJR19DR1JPVVBTPXkKQ09ORklHX0NHUk9VUF9GUkVFWkVSPXkKQ09ORklHX0NHUk9VUF9ERVZJ
Q0U9eQpDT05GSUdfQ1BVU0VUUz15CkNPTkZJR19QUk9DX1BJRF9DUFVTRVQ9eQpDT05GSUdfQ0dS
T1VQX0NQVUFDQ1Q9eQpDT05GSUdfUkVTT1VSQ0VfQ09VTlRFUlM9eQpDT05GSUdfQ0dST1VQX1BF
UkY9eQpDT05GSUdfQ0dST1VQX1NDSEVEPXkKQ09ORklHX0ZBSVJfR1JPVVBfU0NIRUQ9eQpDT05G
SUdfQkxLX0NHUk9VUD15CkNPTkZJR19OQU1FU1BBQ0VTPXkKQ09ORklHX1VUU19OUz15CkNPTkZJ
R19JUENfTlM9eQpDT05GSUdfUElEX05TPXkKQ09ORklHX05FVF9OUz15CkNPTkZJR19TQ0hFRF9B
VVRPR1JPVVA9eQpDT05GSUdfUkVMQVk9eQpDT05GSUdfQkxLX0RFVl9JTklUUkQ9eQpDT05GSUdf
SU5JVFJBTUZTX1NPVVJDRT0iIgpDT05GSUdfUkRfR1pJUD15CkNPTkZJR19SRF9CWklQMj15CkNP
TkZJR19SRF9MWk1BPXkKQ09ORklHX1JEX1haPXkKQ09ORklHX1JEX0xaTz15CkNPTkZJR19DQ19P
UFRJTUlaRV9GT1JfU0laRT15CkNPTkZJR19TWVNDVEw9eQpDT05GSUdfQU5PTl9JTk9ERVM9eQpD
T05GSUdfVUlEMTY9eQpDT05GSUdfS0FMTFNZTVM9eQpDT05GSUdfSE9UUExVRz15CkNPTkZJR19Q
UklOVEs9eQpDT05GSUdfQlVHPXkKQ09ORklHX0VMRl9DT1JFPXkKQ09ORklHX1BDU1BLUl9QTEFU
Rk9STT15CkNPTkZJR19IQVZFX1BDU1BLUl9QTEFURk9STT15CkNPTkZJR19CQVNFX0ZVTEw9eQpD
T05GSUdfRlVURVg9eQpDT05GSUdfRVBPTEw9eQpDT05GSUdfU0lHTkFMRkQ9eQpDT05GSUdfVElN
RVJGRD15CkNPTkZJR19FVkVOVEZEPXkKQ09ORklHX1NITUVNPXkKQ09ORklHX0FJTz15CkNPTkZJ
R19IQVZFX1BFUkZfRVZFTlRTPXkKCkNPTkZJR19QRVJGX0VWRU5UUz15CkNPTkZJR19WTV9FVkVO
VF9DT1VOVEVSUz15CkNPTkZJR19QQ0lfUVVJUktTPXkKQ09ORklHX1NMQUI9eQpDT05GSUdfUFJP
RklMSU5HPXkKQ09ORklHX1RSQUNFUE9JTlRTPXkKQ09ORklHX09QUk9GSUxFPW0KQ09ORklHX0hB
VkVfT1BST0ZJTEU9eQpDT05GSUdfT1BST0ZJTEVfTk1JX1RJTUVSPXkKQ09ORklHX0pVTVBfTEFC
RUw9eQpDT05GSUdfSEFWRV9FRkZJQ0lFTlRfVU5BTElHTkVEX0FDQ0VTUz15CkNPTkZJR19VU0VS
X1JFVFVSTl9OT1RJRklFUj15CkNPTkZJR19IQVZFX0lPUkVNQVBfUFJPVD15CkNPTkZJR19IQVZF
X0tQUk9CRVM9eQpDT05GSUdfSEFWRV9LUkVUUFJPQkVTPXkKQ09ORklHX0hBVkVfT1BUUFJPQkVT
PXkKQ09ORklHX0hBVkVfQVJDSF9UUkFDRUhPT0s9eQpDT05GSUdfSEFWRV9ETUFfQVRUUlM9eQpD
T05GSUdfVVNFX0dFTkVSSUNfU01QX0hFTFBFUlM9eQpDT05GSUdfR0VORVJJQ19TTVBfSURMRV9U
SFJFQUQ9eQpDT05GSUdfSEFWRV9SRUdTX0FORF9TVEFDS19BQ0NFU1NfQVBJPXkKQ09ORklHX0hB
VkVfRE1BX0FQSV9ERUJVRz15CkNPTkZJR19IQVZFX0hXX0JSRUFLUE9JTlQ9eQpDT05GSUdfSEFW
RV9NSVhFRF9CUkVBS1BPSU5UU19SRUdTPXkKQ09ORklHX0hBVkVfVVNFUl9SRVRVUk5fTk9USUZJ
RVI9eQpDT05GSUdfSEFWRV9QRVJGX0VWRU5UU19OTUk9eQpDT05GSUdfSEFWRV9BUkNIX0pVTVBf
TEFCRUw9eQpDT05GSUdfQVJDSF9IQVZFX05NSV9TQUZFX0NNUFhDSEc9eQpDT05GSUdfSEFWRV9D
TVBYQ0hHX0xPQ0FMPXkKQ09ORklHX0hBVkVfQ01QWENIR19ET1VCTEU9eQpDT05GSUdfQVJDSF9X
QU5UX0NPTVBBVF9JUENfUEFSU0VfVkVSU0lPTj15CkNPTkZJR19BUkNIX1dBTlRfT0xEX0NPTVBB
VF9JUEM9eQpDT05GSUdfSEFWRV9BUkNIX1NFQ0NPTVBfRklMVEVSPXkKQ09ORklHX1NFQ0NPTVBf
RklMVEVSPXkKCkNPTkZJR19TTEFCSU5GTz15CkNPTkZJR19SVF9NVVRFWEVTPXkKQ09ORklHX0JB
U0VfU01BTEw9MApDT05GSUdfTU9EVUxFUz15CkNPTkZJR19NT0RVTEVfRk9SQ0VfTE9BRD15CkNP
TkZJR19NT0RVTEVfVU5MT0FEPXkKQ09ORklHX01PRFVMRV9GT1JDRV9VTkxPQUQ9eQpDT05GSUdf
TU9EVkVSU0lPTlM9eQpDT05GSUdfU1RPUF9NQUNISU5FPXkKQ09ORklHX0JMT0NLPXkKQ09ORklH
X0JMS19ERVZfQlNHPXkKQ09ORklHX0JMS19ERVZfQlNHTElCPXkKQ09ORklHX0JMS19ERVZfSU5U
RUdSSVRZPXkKCkNPTkZJR19QQVJUSVRJT05fQURWQU5DRUQ9eQpDT05GSUdfQUNPUk5fUEFSVElU
SU9OPXkKQ09ORklHX0FDT1JOX1BBUlRJVElPTl9JQ1M9eQpDT05GSUdfQUNPUk5fUEFSVElUSU9O
X1JJU0NJWD15CkNPTkZJR19PU0ZfUEFSVElUSU9OPXkKQ09ORklHX0FNSUdBX1BBUlRJVElPTj15
CkNPTkZJR19BVEFSSV9QQVJUSVRJT049eQpDT05GSUdfTUFDX1BBUlRJVElPTj15CkNPTkZJR19N
U0RPU19QQVJUSVRJT049eQpDT05GSUdfQlNEX0RJU0tMQUJFTD15CkNPTkZJR19NSU5JWF9TVUJQ
QVJUSVRJT049eQpDT05GSUdfU09MQVJJU19YODZfUEFSVElUSU9OPXkKQ09ORklHX1VOSVhXQVJF
X0RJU0tMQUJFTD15CkNPTkZJR19MRE1fUEFSVElUSU9OPXkKQ09ORklHX1NHSV9QQVJUSVRJT049
eQpDT05GSUdfVUxUUklYX1BBUlRJVElPTj15CkNPTkZJR19TVU5fUEFSVElUSU9OPXkKQ09ORklH
X0tBUk1BX1BBUlRJVElPTj15CkNPTkZJR19FRklfUEFSVElUSU9OPXkKQ09ORklHX0JMT0NLX0NP
TVBBVD15CgpDT05GSUdfSU9TQ0hFRF9OT09QPXkKQ09ORklHX0lPU0NIRURfREVBRExJTkU9eQpD
T05GSUdfSU9TQ0hFRF9DRlE9eQpDT05GSUdfQ0ZRX0dST1VQX0lPU0NIRUQ9eQpDT05GSUdfREVG
QVVMVF9DRlE9eQpDT05GSUdfREVGQVVMVF9JT1NDSEVEPSJjZnEiCkNPTkZJR19QUkVFTVBUX05P
VElGSUVSUz15CkNPTkZJR19QQURBVEE9eQpDT05GSUdfSU5MSU5FX1NQSU5fVU5MT0NLX0lSUT15
CkNPTkZJR19JTkxJTkVfUkVBRF9VTkxPQ0s9eQpDT05GSUdfSU5MSU5FX1JFQURfVU5MT0NLX0lS
UT15CkNPTkZJR19JTkxJTkVfV1JJVEVfVU5MT0NLPXkKQ09ORklHX0lOTElORV9XUklURV9VTkxP
Q0tfSVJRPXkKQ09ORklHX01VVEVYX1NQSU5fT05fT1dORVI9eQpDT05GSUdfRlJFRVpFUj15CgpD
T05GSUdfWk9ORV9ETUE9eQpDT05GSUdfU01QPXkKQ09ORklHX1g4Nl9YMkFQSUM9eQpDT05GSUdf
WDg2X01QUEFSU0U9eQpDT05GSUdfWDg2X1NVUFBPUlRTX01FTU9SWV9GQUlMVVJFPXkKQ09ORklH
X1NDSEVEX09NSVRfRlJBTUVfUE9JTlRFUj15CkNPTkZJR19QQVJBVklSVF9HVUVTVD15CkNPTkZJ
R19LVk1fQ0xPQ0s9eQpDT05GSUdfS1ZNX0dVRVNUPXkKQ09ORklHX1BBUkFWSVJUPXkKQ09ORklH
X1BBUkFWSVJUX0NMT0NLPXkKQ09ORklHX05PX0JPT1RNRU09eQpDT05GSUdfTUVNVEVTVD15CkNP
TkZJR19HRU5FUklDX0NQVT15CkNPTkZJR19YODZfSU5URVJOT0RFX0NBQ0hFX1NISUZUPTYKQ09O
RklHX1g4Nl9DTVBYQ0hHPXkKQ09ORklHX1g4Nl9MMV9DQUNIRV9TSElGVD02CkNPTkZJR19YODZf
WEFERD15CkNPTkZJR19YODZfV1BfV09SS1NfT0s9eQpDT05GSUdfWDg2X1RTQz15CkNPTkZJR19Y
ODZfQ01QWENIRzY0PXkKQ09ORklHX1g4Nl9DTU9WPXkKQ09ORklHX1g4Nl9NSU5JTVVNX0NQVV9G
QU1JTFk9NjQKQ09ORklHX1g4Nl9ERUJVR0NUTE1TUj15CkNPTkZJR19DUFVfU1VQX0lOVEVMPXkK
Q09ORklHX0NQVV9TVVBfQU1EPXkKQ09ORklHX0NQVV9TVVBfQ0VOVEFVUj15CkNPTkZJR19IUEVU
X1RJTUVSPXkKQ09ORklHX0hQRVRfRU1VTEFURV9SVEM9eQpDT05GSUdfRE1JPXkKQ09ORklHX0dB
UlRfSU9NTVU9eQpDT05GSUdfQ0FMR0FSWV9JT01NVT15CkNPTkZJR19DQUxHQVJZX0lPTU1VX0VO
QUJMRURfQllfREVGQVVMVD15CkNPTkZJR19TV0lPVExCPXkKQ09ORklHX0lPTU1VX0hFTFBFUj15
CkNPTkZJR19OUl9DUFVTPTQKQ09ORklHX1NDSEVEX1NNVD15CkNPTkZJR19TQ0hFRF9NQz15CkNP
TkZJR19QUkVFTVBUX1ZPTFVOVEFSWT15CkNPTkZJR19YODZfTE9DQUxfQVBJQz15CkNPTkZJR19Y
ODZfSU9fQVBJQz15CkNPTkZJR19YODZfUkVST1VURV9GT1JfQlJPS0VOX0JPT1RfSVJRUz15CkNP
TkZJR19YODZfTUNFPXkKQ09ORklHX1g4Nl9NQ0VfSU5URUw9eQpDT05GSUdfWDg2X01DRV9BTUQ9
eQpDT05GSUdfWDg2X01DRV9USFJFU0hPTEQ9eQpDT05GSUdfWDg2X01DRV9JTkpFQ1Q9bQpDT05G
SUdfWDg2X1RIRVJNQUxfVkVDVE9SPXkKQ09ORklHX0k4Sz1tCkNPTkZJR19NSUNST0NPREU9bQpD
T05GSUdfTUlDUk9DT0RFX0lOVEVMPXkKQ09ORklHX01JQ1JPQ09ERV9BTUQ9eQpDT05GSUdfTUlD
Uk9DT0RFX09MRF9JTlRFUkZBQ0U9eQpDT05GSUdfWDg2X01TUj1tCkNPTkZJR19YODZfQ1BVSUQ9
bQpDT05GSUdfQVJDSF9QSFlTX0FERFJfVF82NEJJVD15CkNPTkZJR19BUkNIX0RNQV9BRERSX1Rf
NjRCSVQ9eQpDT05GSUdfRElSRUNUX0dCUEFHRVM9eQpDT05GSUdfTlVNQT15CkNPTkZJR19BTURf
TlVNQT15CkNPTkZJR19YODZfNjRfQUNQSV9OVU1BPXkKQ09ORklHX05PREVTX1NQQU5fT1RIRVJf
Tk9ERVM9eQpDT05GSUdfTlVNQV9FTVU9eQpDT05GSUdfTk9ERVNfU0hJRlQ9NgpDT05GSUdfQVJD
SF9TUEFSU0VNRU1fRU5BQkxFPXkKQ09ORklHX0FSQ0hfU1BBUlNFTUVNX0RFRkFVTFQ9eQpDT05G
SUdfQVJDSF9TRUxFQ1RfTUVNT1JZX01PREVMPXkKQ09ORklHX0FSQ0hfTUVNT1JZX1BST0JFPXkK
Q09ORklHX0FSQ0hfUFJPQ19LQ09SRV9URVhUPXkKQ09ORklHX0lMTEVHQUxfUE9JTlRFUl9WQUxV
RT0weGRlYWQwMDAwMDAwMDAwMDAKQ09ORklHX1NFTEVDVF9NRU1PUllfTU9ERUw9eQpDT05GSUdf
U1BBUlNFTUVNX01BTlVBTD15CkNPTkZJR19TUEFSU0VNRU09eQpDT05GSUdfTkVFRF9NVUxUSVBM
RV9OT0RFUz15CkNPTkZJR19IQVZFX01FTU9SWV9QUkVTRU5UPXkKQ09ORklHX1NQQVJTRU1FTV9F
WFRSRU1FPXkKQ09ORklHX1NQQVJTRU1FTV9WTUVNTUFQX0VOQUJMRT15CkNPTkZJR19TUEFSU0VN
RU1fQUxMT0NfTUVNX01BUF9UT0dFVEhFUj15CkNPTkZJR19TUEFSU0VNRU1fVk1FTU1BUD15CkNP
TkZJR19IQVZFX01FTUJMT0NLPXkKQ09ORklHX0hBVkVfTUVNQkxPQ0tfTk9ERV9NQVA9eQpDT05G
SUdfQVJDSF9ESVNDQVJEX01FTUJMT0NLPXkKQ09ORklHX01FTU9SWV9JU09MQVRJT049eQpDT05G
SUdfTUVNT1JZX0hPVFBMVUc9eQpDT05GSUdfTUVNT1JZX0hPVFBMVUdfU1BBUlNFPXkKQ09ORklH
X01FTU9SWV9IT1RSRU1PVkU9eQpDT05GSUdfUEFHRUZMQUdTX0VYVEVOREVEPXkKQ09ORklHX1NQ
TElUX1BUTE9DS19DUFVTPTQKQ09ORklHX0NPTVBBQ1RJT049eQpDT05GSUdfTUlHUkFUSU9OPXkK
Q09ORklHX1BIWVNfQUREUl9UXzY0QklUPXkKQ09ORklHX1pPTkVfRE1BX0ZMQUc9MQpDT05GSUdf
Qk9VTkNFPXkKQ09ORklHX1ZJUlRfVE9fQlVTPXkKQ09ORklHX01NVV9OT1RJRklFUj15CkNPTkZJ
R19LU009eQpDT05GSUdfREVGQVVMVF9NTUFQX01JTl9BRERSPTY1NTM2CkNPTkZJR19BUkNIX1NV
UFBPUlRTX01FTU9SWV9GQUlMVVJFPXkKQ09ORklHX01FTU9SWV9GQUlMVVJFPXkKQ09ORklHX0hX
UE9JU09OX0lOSkVDVD1tCkNPTkZJR19UUkFOU1BBUkVOVF9IVUdFUEFHRT15CkNPTkZJR19UUkFO
U1BBUkVOVF9IVUdFUEFHRV9NQURWSVNFPXkKQ09ORklHX0NST1NTX01FTU9SWV9BVFRBQ0g9eQpD
T05GSUdfQ0xFQU5DQUNIRT15CkNPTkZJR19YODZfUkVTRVJWRV9MT1c9NjQKQ09ORklHX01UUlI9
eQpDT05GSUdfTVRSUl9TQU5JVElaRVI9eQpDT05GSUdfTVRSUl9TQU5JVElaRVJfRU5BQkxFX0RF
RkFVTFQ9MQpDT05GSUdfTVRSUl9TQU5JVElaRVJfU1BBUkVfUkVHX05SX0RFRkFVTFQ9MQpDT05G
SUdfWDg2X1BBVD15CkNPTkZJR19BUkNIX1VTRVNfUEdfVU5DQUNIRUQ9eQpDT05GSUdfQVJDSF9S
QU5ET009eQpDT05GSUdfRUZJPXkKQ09ORklHX0VGSV9TVFVCPXkKQ09ORklHX1NFQ0NPTVA9eQpD
T05GSUdfQ0NfU1RBQ0tQUk9URUNUT1I9eQpDT05GSUdfSFpfMTAwMD15CkNPTkZJR19IWj0xMDAw
CkNPTkZJR19TQ0hFRF9IUlRJQ0s9eQpDT05GSUdfS0VYRUM9eQpDT05GSUdfQ1JBU0hfRFVNUD15
CkNPTkZJR19QSFlTSUNBTF9TVEFSVD0weDEwMDAwMDAKQ09ORklHX1JFTE9DQVRBQkxFPXkKQ09O
RklHX1BIWVNJQ0FMX0FMSUdOPTB4MTAwMDAwMApDT05GSUdfSE9UUExVR19DUFU9eQpDT05GSUdf
QVJDSF9FTkFCTEVfTUVNT1JZX0hPVFBMVUc9eQpDT05GSUdfQVJDSF9FTkFCTEVfTUVNT1JZX0hP
VFJFTU9WRT15CkNPTkZJR19VU0VfUEVSQ1BVX05VTUFfTk9ERV9JRD15CgpDT05GSUdfQVJDSF9I
SUJFUk5BVElPTl9IRUFERVI9eQpDT05GSUdfU1VTUEVORD15CkNPTkZJR19TVVNQRU5EX0ZSRUVa
RVI9eQpDT05GSUdfSElCRVJOQVRFX0NBTExCQUNLUz15CkNPTkZJR19ISUJFUk5BVElPTj15CkNP
TkZJR19QTV9TVERfUEFSVElUSU9OPSIiCkNPTkZJR19QTV9TTEVFUD15CkNPTkZJR19QTV9TTEVF
UF9TTVA9eQpDT05GSUdfUE1fUlVOVElNRT15CkNPTkZJR19QTT15CkNPTkZJR19QTV9ERUJVRz15
CkNPTkZJR19QTV9BRFZBTkNFRF9ERUJVRz15CkNPTkZJR19QTV9TTEVFUF9ERUJVRz15CkNPTkZJ
R19BQ1BJPXkKQ09ORklHX0FDUElfU0xFRVA9eQpDT05GSUdfQUNQSV9BQz1tCkNPTkZJR19BQ1BJ
X0JBVFRFUlk9bQpDT05GSUdfQUNQSV9CVVRUT049bQpDT05GSUdfQUNQSV9WSURFTz1tCkNPTkZJ
R19BQ1BJX0ZBTj1tCkNPTkZJR19BQ1BJX0RPQ0s9eQpDT05GSUdfQUNQSV9QUk9DRVNTT1I9bQpD
T05GSUdfQUNQSV9JUE1JPW0KQ09ORklHX0FDUElfSE9UUExVR19DUFU9eQpDT05GSUdfQUNQSV9Q
Uk9DRVNTT1JfQUdHUkVHQVRPUj1tCkNPTkZJR19BQ1BJX1RIRVJNQUw9bQpDT05GSUdfQUNQSV9O
VU1BPXkKQ09ORklHX0FDUElfQkxBQ0tMSVNUX1lFQVI9MApDT05GSUdfQUNQSV9QQ0lfU0xPVD1t
CkNPTkZJR19YODZfUE1fVElNRVI9eQpDT05GSUdfQUNQSV9DT05UQUlORVI9bQpDT05GSUdfQUNQ
SV9IT1RQTFVHX01FTU9SWT1tCkNPTkZJR19BQ1BJX1NCUz1tCkNPTkZJR19BQ1BJX0hFRD15CkNP
TkZJR19BQ1BJX0FQRUk9eQpDT05GSUdfQUNQSV9BUEVJX0dIRVM9eQpDT05GSUdfQUNQSV9BUEVJ
X1BDSUVBRVI9eQpDT05GSUdfQUNQSV9BUEVJX01FTU9SWV9GQUlMVVJFPXkKQ09ORklHX1NGST15
CgpDT05GSUdfQ1BVX0ZSRVE9eQpDT05GSUdfQ1BVX0ZSRVFfVEFCTEU9eQpDT05GSUdfQ1BVX0ZS
RVFfU1RBVD1tCkNPTkZJR19DUFVfRlJFUV9ERUZBVUxUX0dPVl9PTkRFTUFORD15CkNPTkZJR19D
UFVfRlJFUV9HT1ZfUEVSRk9STUFOQ0U9eQpDT05GSUdfQ1BVX0ZSRVFfR09WX1BPV0VSU0FWRT1t
CkNPTkZJR19DUFVfRlJFUV9HT1ZfVVNFUlNQQUNFPW0KQ09ORklHX0NQVV9GUkVRX0dPVl9PTkRF
TUFORD15CkNPTkZJR19DUFVfRlJFUV9HT1ZfQ09OU0VSVkFUSVZFPW0KCkNPTkZJR19YODZfUEND
X0NQVUZSRVE9bQpDT05GSUdfWDg2X0FDUElfQ1BVRlJFUT1tCkNPTkZJR19YODZfUE9XRVJOT1df
Szg9bQpDT05GSUdfWDg2X1NQRUVEU1RFUF9DRU5UUklOTz1tCkNPTkZJR19YODZfUDRfQ0xPQ0tN
T0Q9bQoKQ09ORklHX1g4Nl9TUEVFRFNURVBfTElCPW0KQ09ORklHX0NQVV9JRExFPXkKQ09ORklH
X0NQVV9JRExFX0dPVl9MQURERVI9eQpDT05GSUdfQ1BVX0lETEVfR09WX01FTlU9eQpDT05GSUdf
SU5URUxfSURMRT15CgpDT05GSUdfSTczMDBfSURMRV9JT0FUX0NIQU5ORUw9eQpDT05GSUdfSTcz
MDBfSURMRT1tCgpDT05GSUdfUENJPXkKQ09ORklHX1BDSV9ESVJFQ1Q9eQpDT05GSUdfUENJX01N
Q09ORklHPXkKQ09ORklHX1BDSV9ET01BSU5TPXkKQ09ORklHX1BDSUVQT1JUQlVTPXkKQ09ORklH
X0hPVFBMVUdfUENJX1BDSUU9eQpDT05GSUdfUENJRUFFUj15CkNPTkZJR19QQ0lFQUVSX0lOSkVD
VD1tCkNPTkZJR19QQ0lFQVNQTT15CkNPTkZJR19QQ0lFQVNQTV9ERUZBVUxUPXkKQ09ORklHX1BD
SUVfUE1FPXkKQ09ORklHX0FSQ0hfU1VQUE9SVFNfTVNJPXkKQ09ORklHX1BDSV9NU0k9eQpDT05G
SUdfUENJX1NUVUI9bQpDT05GSUdfSFRfSVJRPXkKQ09ORklHX1BDSV9BVFM9eQpDT05GSUdfUENJ
X0lPVj15CkNPTkZJR19QQ0lfUFJJPXkKQ09ORklHX1BDSV9QQVNJRD15CkNPTkZJR19QQ0lfSU9B
UElDPXkKQ09ORklHX1BDSV9MQUJFTD15CkNPTkZJR19JU0FfRE1BX0FQST15CkNPTkZJR19BTURf
TkI9eQpDT05GSUdfUENDQVJEPW0KQ09ORklHX1BDTUNJQT1tCkNPTkZJR19QQ01DSUFfTE9BRF9D
SVM9eQpDT05GSUdfQ0FSREJVUz15CgpDT05GSUdfWUVOVEE9bQpDT05GSUdfWUVOVEFfTzI9eQpD
T05GSUdfWUVOVEFfUklDT0g9eQpDT05GSUdfWUVOVEFfVEk9eQpDT05GSUdfWUVOVEFfRU5FX1RV
TkU9eQpDT05GSUdfWUVOVEFfVE9TSElCQT15CkNPTkZJR19QRDY3Mjk9bQpDT05GSUdfSTgyMDky
PW0KQ09ORklHX1BDQ0FSRF9OT05TVEFUSUM9eQpDT05GSUdfSE9UUExVR19QQ0k9eQpDT05GSUdf
SE9UUExVR19QQ0lfRkFLRT1tCkNPTkZJR19IT1RQTFVHX1BDSV9BQ1BJPXkKQ09ORklHX0hPVFBM
VUdfUENJX0FDUElfSUJNPW0KQ09ORklHX0hPVFBMVUdfUENJX0NQQ0k9eQpDT05GSUdfSE9UUExV
R19QQ0lfQ1BDSV9aVDU1NTA9bQpDT05GSUdfSE9UUExVR19QQ0lfQ1BDSV9HRU5FUklDPW0KQ09O
RklHX0hPVFBMVUdfUENJX1NIUEM9bQoKQ09ORklHX0JJTkZNVF9FTEY9eQpDT05GSUdfQ09NUEFU
X0JJTkZNVF9FTEY9eQpDT05GSUdfQVJDSF9CSU5GTVRfRUxGX1JBTkRPTUlaRV9QSUU9eQpDT05G
SUdfQ09SRV9EVU1QX0RFRkFVTFRfRUxGX0hFQURFUlM9eQpDT05GSUdfQklORk1UX01JU0M9bQpD
T05GSUdfSUEzMl9FTVVMQVRJT049eQpDT05GSUdfSUEzMl9BT1VUPXkKQ09ORklHX0NPTVBBVD15
CkNPTkZJR19DT01QQVRfRk9SX1U2NF9BTElHTk1FTlQ9eQpDT05GSUdfU1lTVklQQ19DT01QQVQ9
eQpDT05GSUdfS0VZU19DT01QQVQ9eQpDT05GSUdfSEFWRV9URVhUX1BPS0VfU01QPXkKQ09ORklH
X1g4Nl9ERVZfRE1BX09QUz15CkNPTkZJR19ORVQ9eQpDT05GSUdfQ09NUEFUX05FVExJTktfTUVT
U0FHRVM9eQoKQ09ORklHX1BBQ0tFVD15CkNPTkZJR19VTklYPXkKQ09ORklHX1hGUk09eQpDT05G
SUdfWEZSTV9BTEdPPW0KQ09ORklHX1hGUk1fVVNFUj1tCkNPTkZJR19YRlJNX1NVQl9QT0xJQ1k9
eQpDT05GSUdfWEZSTV9NSUdSQVRFPXkKQ09ORklHX1hGUk1fSVBDT01QPW0KQ09ORklHX05FVF9L
RVk9bQpDT05GSUdfTkVUX0tFWV9NSUdSQVRFPXkKQ09ORklHX0lORVQ9eQpDT05GSUdfSVBfTVVM
VElDQVNUPXkKQ09ORklHX0lQX0FEVkFOQ0VEX1JPVVRFUj15CkNPTkZJR19JUF9GSUJfVFJJRV9T
VEFUUz15CkNPTkZJR19JUF9NVUxUSVBMRV9UQUJMRVM9eQpDT05GSUdfSVBfUk9VVEVfTVVMVElQ
QVRIPXkKQ09ORklHX0lQX1JPVVRFX1ZFUkJPU0U9eQpDT05GSUdfSVBfUk9VVEVfQ0xBU1NJRD15
CkNPTkZJR19ORVRfSVBJUD1tCkNPTkZJR19ORVRfSVBHUkVfREVNVVg9bQpDT05GSUdfTkVUX0lQ
R1JFPW0KQ09ORklHX05FVF9JUEdSRV9CUk9BRENBU1Q9eQpDT05GSUdfSVBfTVJPVVRFPXkKQ09O
RklHX0lQX01ST1VURV9NVUxUSVBMRV9UQUJMRVM9eQpDT05GSUdfSVBfUElNU01fVjE9eQpDT05G
SUdfSVBfUElNU01fVjI9eQpDT05GSUdfU1lOX0NPT0tJRVM9eQpDT05GSUdfSU5FVF9BSD1tCkNP
TkZJR19JTkVUX0VTUD1tCkNPTkZJR19JTkVUX0lQQ09NUD1tCkNPTkZJR19JTkVUX1hGUk1fVFVO
TkVMPW0KQ09ORklHX0lORVRfVFVOTkVMPW0KQ09ORklHX0lORVRfWEZSTV9NT0RFX1RSQU5TUE9S
VD1tCkNPTkZJR19JTkVUX1hGUk1fTU9ERV9UVU5ORUw9bQpDT05GSUdfSU5FVF9YRlJNX01PREVf
QkVFVD1tCkNPTkZJR19JTkVUX0xSTz1tCkNPTkZJR19JTkVUX0RJQUc9bQpDT05GSUdfSU5FVF9U
Q1BfRElBRz1tCkNPTkZJR19UQ1BfQ09OR19BRFZBTkNFRD15CkNPTkZJR19UQ1BfQ09OR19CSUM9
bQpDT05GSUdfVENQX0NPTkdfQ1VCSUM9eQpDT05GSUdfVENQX0NPTkdfV0VTVFdPT0Q9bQpDT05G
SUdfVENQX0NPTkdfSFRDUD1tCkNPTkZJR19UQ1BfQ09OR19IU1RDUD1tCkNPTkZJR19UQ1BfQ09O
R19IWUJMQT1tCkNPTkZJR19UQ1BfQ09OR19WRUdBUz1tCkNPTkZJR19UQ1BfQ09OR19TQ0FMQUJM
RT1tCkNPTkZJR19UQ1BfQ09OR19MUD1tCkNPTkZJR19UQ1BfQ09OR19WRU5PPW0KQ09ORklHX1RD
UF9DT05HX1lFQUg9bQpDT05GSUdfVENQX0NPTkdfSUxMSU5PSVM9bQpDT05GSUdfREVGQVVMVF9D
VUJJQz15CkNPTkZJR19ERUZBVUxUX1RDUF9DT05HPSJjdWJpYyIKQ09ORklHX1RDUF9NRDVTSUc9
eQpDT05GSUdfSVBWNj15CkNPTkZJR19JUFY2X1BSSVZBQ1k9eQpDT05GSUdfSVBWNl9ST1VURVJf
UFJFRj15CkNPTkZJR19JUFY2X1JPVVRFX0lORk89eQpDT05GSUdfSVBWNl9PUFRJTUlTVElDX0RB
RD15CkNPTkZJR19JTkVUNl9BSD1tCkNPTkZJR19JTkVUNl9FU1A9bQpDT05GSUdfSU5FVDZfSVBD
T01QPW0KQ09ORklHX0lQVjZfTUlQNj15CkNPTkZJR19JTkVUNl9YRlJNX1RVTk5FTD1tCkNPTkZJ
R19JTkVUNl9UVU5ORUw9bQpDT05GSUdfSU5FVDZfWEZSTV9NT0RFX1RSQU5TUE9SVD1tCkNPTkZJ
R19JTkVUNl9YRlJNX01PREVfVFVOTkVMPW0KQ09ORklHX0lORVQ2X1hGUk1fTU9ERV9CRUVUPW0K
Q09ORklHX0lORVQ2X1hGUk1fTU9ERV9ST1VURU9QVElNSVpBVElPTj1tCkNPTkZJR19JUFY2X1NJ
VD1tCkNPTkZJR19JUFY2X1NJVF82UkQ9eQpDT05GSUdfSVBWNl9ORElTQ19OT0RFVFlQRT15CkNP
TkZJR19JUFY2X1RVTk5FTD1tCkNPTkZJR19JUFY2X01VTFRJUExFX1RBQkxFUz15CkNPTkZJR19J
UFY2X1NVQlRSRUVTPXkKQ09ORklHX0lQVjZfTVJPVVRFPXkKQ09ORklHX0lQVjZfTVJPVVRFX01V
TFRJUExFX1RBQkxFUz15CkNPTkZJR19JUFY2X1BJTVNNX1YyPXkKQ09ORklHX05FVFdPUktfU0VD
TUFSSz15CkNPTkZJR19ORVRGSUxURVI9eQpDT05GSUdfTkVURklMVEVSX0FEVkFOQ0VEPXkKQ09O
RklHX0JSSURHRV9ORVRGSUxURVI9eQoKQ09ORklHX05FVEZJTFRFUl9ORVRMSU5LPW0KQ09ORklH
X05FVEZJTFRFUl9ORVRMSU5LX1FVRVVFPW0KQ09ORklHX05FVEZJTFRFUl9ORVRMSU5LX0xPRz1t
CkNPTkZJR19ORl9DT05OVFJBQ0s9bQpDT05GSUdfTkZfQ09OTlRSQUNLX01BUks9eQpDT05GSUdf
TkZfQ09OTlRSQUNLX1NFQ01BUks9eQpDT05GSUdfTkZfQ09OTlRSQUNLX1pPTkVTPXkKQ09ORklH
X05GX0NPTk5UUkFDS19QUk9DRlM9eQpDT05GSUdfTkZfQ09OTlRSQUNLX0VWRU5UUz15CkNPTkZJ
R19ORl9DT05OVFJBQ0tfVElNRVNUQU1QPXkKQ09ORklHX05GX0NUX1BST1RPX0RDQ1A9bQpDT05G
SUdfTkZfQ1RfUFJPVE9fR1JFPW0KQ09ORklHX05GX0NUX1BST1RPX1NDVFA9bQpDT05GSUdfTkZf
Q1RfUFJPVE9fVURQTElURT1tCkNPTkZJR19ORl9DT05OVFJBQ0tfQU1BTkRBPW0KQ09ORklHX05G
X0NPTk5UUkFDS19GVFA9bQpDT05GSUdfTkZfQ09OTlRSQUNLX0gzMjM9bQpDT05GSUdfTkZfQ09O
TlRSQUNLX0lSQz1tCkNPTkZJR19ORl9DT05OVFJBQ0tfQlJPQURDQVNUPW0KQ09ORklHX05GX0NP
Tk5UUkFDS19ORVRCSU9TX05TPW0KQ09ORklHX05GX0NPTk5UUkFDS19TTk1QPW0KQ09ORklHX05G
X0NPTk5UUkFDS19QUFRQPW0KQ09ORklHX05GX0NPTk5UUkFDS19TQU5FPW0KQ09ORklHX05GX0NP
Tk5UUkFDS19TSVA9bQpDT05GSUdfTkZfQ09OTlRSQUNLX1RGVFA9bQpDT05GSUdfTkZfQ1RfTkVU
TElOSz1tCkNPTkZJR19ORVRGSUxURVJfVFBST1hZPW0KQ09ORklHX05FVEZJTFRFUl9YVEFCTEVT
PW0KCkNPTkZJR19ORVRGSUxURVJfWFRfTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfQ09OTk1B
Uks9bQpDT05GSUdfTkVURklMVEVSX1hUX1NFVD1tCgpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdF
VF9BVURJVD1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0NIRUNLU1VNPW0KQ09ORklHX05F
VEZJTFRFUl9YVF9UQVJHRVRfQ0xBU1NJRlk9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9D
T05OTUFSSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX0NPTk5TRUNNQVJLPW0KQ09ORklH
X05FVEZJTFRFUl9YVF9UQVJHRVRfQ1Q9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9EU0NQ
PW0KQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfSEw9bQpDT05GSUdfTkVURklMVEVSX1hUX1RB
UkdFVF9JRExFVElNRVI9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9MRUQ9bQpDT05GSUdf
TkVURklMVEVSX1hUX1RBUkdFVF9NQVJLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfTkZM
T0c9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9ORlFVRVVFPW0KQ09ORklHX05FVEZJTFRF
Ul9YVF9UQVJHRVRfTk9UUkFDSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfVEFSR0VUX1JBVEVFU1Q9
bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9URUU9bQpDT05GSUdfTkVURklMVEVSX1hUX1RB
UkdFVF9UUFJPWFk9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9UUkFDRT1tCkNPTkZJR19O
RVRGSUxURVJfWFRfVEFSR0VUX1NFQ01BUks9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9U
Q1BNU1M9bQpDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9UQ1BPUFRTVFJJUD1tCgpDT05GSUdf
TkVURklMVEVSX1hUX01BVENIX0FERFJUWVBFPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9D
TFVTVEVSPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9DT01NRU5UPW0KQ09ORklHX05FVEZJ
TFRFUl9YVF9NQVRDSF9DT05OQllURVM9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX0NPTk5M
SU1JVD1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ09OTk1BUks9bQpDT05GSUdfTkVURklM
VEVSX1hUX01BVENIX0NPTk5UUkFDSz1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfQ1BVPW0K
Q09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9EQ0NQPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRD
SF9ERVZHUk9VUD1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfRFNDUD1tCkNPTkZJR19ORVRG
SUxURVJfWFRfTUFUQ0hfRUNOPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9FU1A9bQpDT05G
SUdfTkVURklMVEVSX1hUX01BVENIX0hBU0hMSU1JVD1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFU
Q0hfSEVMUEVSPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9ITD1tCkNPTkZJR19ORVRGSUxU
RVJfWFRfTUFUQ0hfSVBSQU5HRT1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfSVBWUz1tCkNP
TkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfTEVOR1RIPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRD
SF9MSU1JVD1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfTUFDPW0KQ09ORklHX05FVEZJTFRF
Ul9YVF9NQVRDSF9NQVJLPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9NVUxUSVBPUlQ9bQpD
T05GSUdfTkVURklMVEVSX1hUX01BVENIX09TRj1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hf
T1dORVI9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1BPTElDWT1tCkNPTkZJR19ORVRGSUxU
RVJfWFRfTUFUQ0hfUEhZU0RFVj1tCkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUEtUVFlQRT1t
CkNPTkZJR19ORVRGSUxURVJfWFRfTUFUQ0hfUVVPVEE9bQpDT05GSUdfTkVURklMVEVSX1hUX01B
VENIX1JBVEVFU1Q9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1JFQUxNPW0KQ09ORklHX05F
VEZJTFRFUl9YVF9NQVRDSF9SRUNFTlQ9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NDVFA9
bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NPQ0tFVD1tCkNPTkZJR19ORVRGSUxURVJfWFRf
TUFUQ0hfU1RBVEU9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1NUQVRJU1RJQz1tCkNPTkZJ
R19ORVRGSUxURVJfWFRfTUFUQ0hfU1RSSU5HPW0KQ09ORklHX05FVEZJTFRFUl9YVF9NQVRDSF9U
Q1BNU1M9bQpDT05GSUdfTkVURklMVEVSX1hUX01BVENIX1RJTUU9bQpDT05GSUdfTkVURklMVEVS
X1hUX01BVENIX1UzMj1tCkNPTkZJR19JUF9TRVQ9bQpDT05GSUdfSVBfU0VUX01BWD0yNTYKQ09O
RklHX0lQX1NFVF9CSVRNQVBfSVA9bQpDT05GSUdfSVBfU0VUX0JJVE1BUF9JUE1BQz1tCkNPTkZJ
R19JUF9TRVRfQklUTUFQX1BPUlQ9bQpDT05GSUdfSVBfU0VUX0hBU0hfSVA9bQpDT05GSUdfSVBf
U0VUX0hBU0hfSVBQT1JUPW0KQ09ORklHX0lQX1NFVF9IQVNIX0lQUE9SVElQPW0KQ09ORklHX0lQ
X1NFVF9IQVNIX0lQUE9SVE5FVD1tCkNPTkZJR19JUF9TRVRfSEFTSF9ORVQ9bQpDT05GSUdfSVBf
U0VUX0hBU0hfTkVUUE9SVD1tCkNPTkZJR19JUF9TRVRfSEFTSF9ORVRJRkFDRT1tCkNPTkZJR19J
UF9TRVRfTElTVF9TRVQ9bQpDT05GSUdfSVBfVlM9bQpDT05GSUdfSVBfVlNfSVBWNj15CkNPTkZJ
R19JUF9WU19UQUJfQklUUz0xMgoKQ09ORklHX0lQX1ZTX1BST1RPX1RDUD15CkNPTkZJR19JUF9W
U19QUk9UT19VRFA9eQpDT05GSUdfSVBfVlNfUFJPVE9fQUhfRVNQPXkKQ09ORklHX0lQX1ZTX1BS
T1RPX0VTUD15CkNPTkZJR19JUF9WU19QUk9UT19BSD15CkNPTkZJR19JUF9WU19QUk9UT19TQ1RQ
PXkKCkNPTkZJR19JUF9WU19SUj1tCkNPTkZJR19JUF9WU19XUlI9bQpDT05GSUdfSVBfVlNfTEM9
bQpDT05GSUdfSVBfVlNfV0xDPW0KQ09ORklHX0lQX1ZTX0xCTEM9bQpDT05GSUdfSVBfVlNfTEJM
Q1I9bQpDT05GSUdfSVBfVlNfREg9bQpDT05GSUdfSVBfVlNfU0g9bQpDT05GSUdfSVBfVlNfU0VE
PW0KQ09ORklHX0lQX1ZTX05RPW0KCkNPTkZJR19JUF9WU19TSF9UQUJfQklUUz04CgpDT05GSUdf
SVBfVlNfRlRQPW0KQ09ORklHX0lQX1ZTX05GQ1Q9eQpDT05GSUdfSVBfVlNfUEVfU0lQPW0KCkNP
TkZJR19ORl9ERUZSQUdfSVBWND1tCkNPTkZJR19ORl9DT05OVFJBQ0tfSVBWND1tCkNPTkZJR19O
Rl9DT05OVFJBQ0tfUFJPQ19DT01QQVQ9eQpDT05GSUdfSVBfTkZfUVVFVUU9bQpDT05GSUdfSVBf
TkZfSVBUQUJMRVM9bQpDT05GSUdfSVBfTkZfTUFUQ0hfQUg9bQpDT05GSUdfSVBfTkZfTUFUQ0hf
RUNOPW0KQ09ORklHX0lQX05GX01BVENIX1RUTD1tCkNPTkZJR19JUF9ORl9GSUxURVI9bQpDT05G
SUdfSVBfTkZfVEFSR0VUX1JFSkVDVD1tCkNPTkZJR19JUF9ORl9UQVJHRVRfVUxPRz1tCkNPTkZJ
R19ORl9OQVQ9bQpDT05GSUdfTkZfTkFUX05FRURFRD15CkNPTkZJR19JUF9ORl9UQVJHRVRfTUFT
UVVFUkFERT1tCkNPTkZJR19JUF9ORl9UQVJHRVRfTkVUTUFQPW0KQ09ORklHX0lQX05GX1RBUkdF
VF9SRURJUkVDVD1tCkNPTkZJR19ORl9OQVRfU05NUF9CQVNJQz1tCkNPTkZJR19ORl9OQVRfUFJP
VE9fRENDUD1tCkNPTkZJR19ORl9OQVRfUFJPVE9fR1JFPW0KQ09ORklHX05GX05BVF9QUk9UT19V
RFBMSVRFPW0KQ09ORklHX05GX05BVF9QUk9UT19TQ1RQPW0KQ09ORklHX05GX05BVF9GVFA9bQpD
T05GSUdfTkZfTkFUX0lSQz1tCkNPTkZJR19ORl9OQVRfVEZUUD1tCkNPTkZJR19ORl9OQVRfQU1B
TkRBPW0KQ09ORklHX05GX05BVF9QUFRQPW0KQ09ORklHX05GX05BVF9IMzIzPW0KQ09ORklHX05G
X05BVF9TSVA9bQpDT05GSUdfSVBfTkZfTUFOR0xFPW0KQ09ORklHX0lQX05GX1RBUkdFVF9DTFVT
VEVSSVA9bQpDT05GSUdfSVBfTkZfVEFSR0VUX0VDTj1tCkNPTkZJR19JUF9ORl9UQVJHRVRfVFRM
PW0KQ09ORklHX0lQX05GX1JBVz1tCkNPTkZJR19JUF9ORl9TRUNVUklUWT1tCkNPTkZJR19JUF9O
Rl9BUlBUQUJMRVM9bQpDT05GSUdfSVBfTkZfQVJQRklMVEVSPW0KQ09ORklHX0lQX05GX0FSUF9N
QU5HTEU9bQoKQ09ORklHX05GX0RFRlJBR19JUFY2PW0KQ09ORklHX05GX0NPTk5UUkFDS19JUFY2
PW0KQ09ORklHX0lQNl9ORl9JUFRBQkxFUz1tCkNPTkZJR19JUDZfTkZfTUFUQ0hfQUg9bQpDT05G
SUdfSVA2X05GX01BVENIX0VVSTY0PW0KQ09ORklHX0lQNl9ORl9NQVRDSF9GUkFHPW0KQ09ORklH
X0lQNl9ORl9NQVRDSF9PUFRTPW0KQ09ORklHX0lQNl9ORl9NQVRDSF9ITD1tCkNPTkZJR19JUDZf
TkZfTUFUQ0hfSVBWNkhFQURFUj1tCkNPTkZJR19JUDZfTkZfTUFUQ0hfTUg9bQpDT05GSUdfSVA2
X05GX01BVENIX1JUPW0KQ09ORklHX0lQNl9ORl9UQVJHRVRfSEw9bQpDT05GSUdfSVA2X05GX0ZJ
TFRFUj1tCkNPTkZJR19JUDZfTkZfVEFSR0VUX1JFSkVDVD1tCkNPTkZJR19JUDZfTkZfTUFOR0xF
PW0KQ09ORklHX0lQNl9ORl9SQVc9bQpDT05GSUdfSVA2X05GX1NFQ1VSSVRZPW0KCkNPTkZJR19E
RUNORVRfTkZfR1JBQlVMQVRPUj1tCkNPTkZJR19CUklER0VfTkZfRUJUQUJMRVM9bQpDT05GSUdf
QlJJREdFX0VCVF9CUk9VVEU9bQpDT05GSUdfQlJJREdFX0VCVF9UX0ZJTFRFUj1tCkNPTkZJR19C
UklER0VfRUJUX1RfTkFUPW0KQ09ORklHX0JSSURHRV9FQlRfODAyXzM9bQpDT05GSUdfQlJJREdF
X0VCVF9BTU9ORz1tCkNPTkZJR19CUklER0VfRUJUX0FSUD1tCkNPTkZJR19CUklER0VfRUJUX0lQ
PW0KQ09ORklHX0JSSURHRV9FQlRfSVA2PW0KQ09ORklHX0JSSURHRV9FQlRfTElNSVQ9bQpDT05G
SUdfQlJJREdFX0VCVF9NQVJLPW0KQ09ORklHX0JSSURHRV9FQlRfUEtUVFlQRT1tCkNPTkZJR19C
UklER0VfRUJUX1NUUD1tCkNPTkZJR19CUklER0VfRUJUX1ZMQU49bQpDT05GSUdfQlJJREdFX0VC
VF9BUlBSRVBMWT1tCkNPTkZJR19CUklER0VfRUJUX0ROQVQ9bQpDT05GSUdfQlJJREdFX0VCVF9N
QVJLX1Q9bQpDT05GSUdfQlJJREdFX0VCVF9SRURJUkVDVD1tCkNPTkZJR19CUklER0VfRUJUX1NO
QVQ9bQpDT05GSUdfQlJJREdFX0VCVF9MT0c9bQpDT05GSUdfQlJJREdFX0VCVF9VTE9HPW0KQ09O
RklHX0JSSURHRV9FQlRfTkZMT0c9bQpDT05GSUdfSVBfRENDUD1tCkNPTkZJR19JTkVUX0RDQ1Bf
RElBRz1tCgpDT05GSUdfSVBfRENDUF9DQ0lEMz15CkNPTkZJR19JUF9EQ0NQX1RGUkNfTElCPXkK
CkNPTkZJR19JUF9TQ1RQPW0KQ09ORklHX1NDVFBfSE1BQ19NRDU9eQpDT05GSUdfUkRTPW0KQ09O
RklHX1JEU19UQ1A9bQpDT05GSUdfVElQQz1tCkNPTkZJR19USVBDX0FEVkFOQ0VEPXkKQ09ORklH
X1RJUENfUE9SVFM9ODE5MQpDT05GSUdfQVRNPW0KQ09ORklHX0FUTV9DTElQPW0KQ09ORklHX0FU
TV9MQU5FPW0KQ09ORklHX0FUTV9NUE9BPW0KQ09ORklHX0FUTV9CUjI2ODQ9bQpDT05GSUdfTDJU
UD1tCkNPTkZJR19MMlRQX0RFQlVHRlM9bQpDT05GSUdfTDJUUF9WMz15CkNPTkZJR19MMlRQX0lQ
PW0KQ09ORklHX0wyVFBfRVRIPW0KQ09ORklHX1NUUD1tCkNPTkZJR19HQVJQPW0KQ09ORklHX0JS
SURHRT1tCkNPTkZJR19CUklER0VfSUdNUF9TTk9PUElORz15CkNPTkZJR19WTEFOXzgwMjFRPW0K
Q09ORklHX1ZMQU5fODAyMVFfR1ZSUD15CkNPTkZJR19ERUNORVQ9bQpDT05GSUdfTExDPW0KQ09O
RklHX0xMQzI9bQpDT05GSUdfSVBYPW0KQ09ORklHX0FUQUxLPW0KQ09ORklHX0RFVl9BUFBMRVRB
TEs9bQpDT05GSUdfSVBERFA9bQpDT05GSUdfSVBERFBfRU5DQVA9eQpDT05GSUdfSVBERFBfREVD
QVA9eQpDT05GSUdfTEFQQj1tCkNPTkZJR19XQU5fUk9VVEVSPW0KQ09ORklHX1BIT05FVD1tCkNP
TkZJR19JRUVFODAyMTU0PW0KQ09ORklHX0lFRUU4MDIxNTRfNkxPV1BBTj1tCkNPTkZJR19ORVRf
U0NIRUQ9eQoKQ09ORklHX05FVF9TQ0hfQ0JRPW0KQ09ORklHX05FVF9TQ0hfSFRCPW0KQ09ORklH
X05FVF9TQ0hfSEZTQz1tCkNPTkZJR19ORVRfU0NIX0FUTT1tCkNPTkZJR19ORVRfU0NIX1BSSU89
bQpDT05GSUdfTkVUX1NDSF9NVUxUSVE9bQpDT05GSUdfTkVUX1NDSF9SRUQ9bQpDT05GSUdfTkVU
X1NDSF9TRkI9bQpDT05GSUdfTkVUX1NDSF9TRlE9bQpDT05GSUdfTkVUX1NDSF9URVFMPW0KQ09O
RklHX05FVF9TQ0hfVEJGPW0KQ09ORklHX05FVF9TQ0hfR1JFRD1tCkNPTkZJR19ORVRfU0NIX0RT
TUFSSz1tCkNPTkZJR19ORVRfU0NIX05FVEVNPW0KQ09ORklHX05FVF9TQ0hfRFJSPW0KQ09ORklH
X05FVF9TQ0hfTVFQUklPPW0KQ09ORklHX05FVF9TQ0hfQ0hPS0U9bQpDT05GSUdfTkVUX1NDSF9R
RlE9bQpDT05GSUdfTkVUX1NDSF9DT0RFTD1tCkNPTkZJR19ORVRfU0NIX0ZRX0NPREVMPW0KQ09O
RklHX05FVF9TQ0hfSU5HUkVTUz1tCgpDT05GSUdfTkVUX0NMUz15CkNPTkZJR19ORVRfQ0xTX0JB
U0lDPW0KQ09ORklHX05FVF9DTFNfVENJTkRFWD1tCkNPTkZJR19ORVRfQ0xTX1JPVVRFND1tCkNP
TkZJR19ORVRfQ0xTX0ZXPW0KQ09ORklHX05FVF9DTFNfVTMyPW0KQ09ORklHX0NMU19VMzJfUEVS
Rj15CkNPTkZJR19DTFNfVTMyX01BUks9eQpDT05GSUdfTkVUX0NMU19SU1ZQPW0KQ09ORklHX05F
VF9DTFNfUlNWUDY9bQpDT05GSUdfTkVUX0NMU19GTE9XPW0KQ09ORklHX05FVF9DTFNfQ0dST1VQ
PXkKQ09ORklHX05FVF9FTUFUQ0g9eQpDT05GSUdfTkVUX0VNQVRDSF9TVEFDSz0zMgpDT05GSUdf
TkVUX0VNQVRDSF9DTVA9bQpDT05GSUdfTkVUX0VNQVRDSF9OQllURT1tCkNPTkZJR19ORVRfRU1B
VENIX1UzMj1tCkNPTkZJR19ORVRfRU1BVENIX01FVEE9bQpDT05GSUdfTkVUX0VNQVRDSF9URVhU
PW0KQ09ORklHX05FVF9DTFNfQUNUPXkKQ09ORklHX05FVF9BQ1RfUE9MSUNFPW0KQ09ORklHX05F
VF9BQ1RfR0FDVD1tCkNPTkZJR19HQUNUX1BST0I9eQpDT05GSUdfTkVUX0FDVF9NSVJSRUQ9bQpD
T05GSUdfTkVUX0FDVF9JUFQ9bQpDT05GSUdfTkVUX0FDVF9OQVQ9bQpDT05GSUdfTkVUX0FDVF9Q
RURJVD1tCkNPTkZJR19ORVRfQUNUX1NJTVA9bQpDT05GSUdfTkVUX0FDVF9TS0JFRElUPW0KQ09O
RklHX05FVF9BQ1RfQ1NVTT1tCkNPTkZJR19ORVRfQ0xTX0lORD15CkNPTkZJR19ORVRfU0NIX0ZJ
Rk89eQpDT05GSUdfRENCPXkKQ09ORklHX0ROU19SRVNPTFZFUj15CkNPTkZJR19CQVRNQU5fQURW
PW0KQ09ORklHX0JBVE1BTl9BRFZfQkxBPXkKQ09ORklHX1JQUz15CkNPTkZJR19SRlNfQUNDRUw9
eQpDT05GSUdfWFBTPXkKQ09ORklHX0JRTD15CkNPTkZJR19CUEZfSklUPXkKCkNPTkZJR19ORVRf
UEtUR0VOPW0KQ09ORklHX05FVF9EUk9QX01PTklUT1I9eQpDT05GSUdfSEFNUkFESU89eQoKQ09O
RklHX0FYMjU9bQpDT05GSUdfTkVUUk9NPW0KQ09ORklHX1JPU0U9bQoKQ09ORklHX01LSVNTPW0K
Q09ORklHXzZQQUNLPW0KQ09ORklHX0JQUUVUSEVSPW0KQ09ORklHX0JBWUNPTV9TRVJfRkRYPW0K
Q09ORklHX0JBWUNPTV9TRVJfSERYPW0KQ09ORklHX0JBWUNPTV9QQVI9bQpDT05GSUdfWUFNPW0K
Q09ORklHX0NBTj1tCkNPTkZJR19DQU5fUkFXPW0KQ09ORklHX0NBTl9CQ009bQpDT05GSUdfQ0FO
X0dXPW0KCkNPTkZJR19DQU5fVkNBTj1tCkNPTkZJR19DQU5fU0xDQU49bQpDT05GSUdfQ0FOX0RF
Vj1tCkNPTkZJR19DQU5fQ0FMQ19CSVRUSU1JTkc9eQpDT05GSUdfQ0FOX01DUDI1MVg9bQpDT05G
SUdfUENIX0NBTj1tCkNPTkZJR19DQU5fU0pBMTAwMD1tCkNPTkZJR19DQU5fRU1TX1BDTUNJQT1t
CkNPTkZJR19DQU5fRU1TX1BDST1tCkNPTkZJR19DQU5fUEVBS19QQ0k9bQpDT05GSUdfQ0FOX1BF
QUtfUENJRUM9eQpDT05GSUdfQ0FOX0tWQVNFUl9QQ0k9bQpDT05GSUdfQ0FOX1BMWF9QQ0k9bQoK
Q09ORklHX0NBTl9FTVNfVVNCPW0KQ09ORklHX0NBTl9FU0RfVVNCMj1tCkNPTkZJR19DQU5fU09G
VElORz1tCkNPTkZJR19DQU5fU09GVElOR19DUz1tCkNPTkZJR19JUkRBPW0KCkNPTkZJR19JUkxB
Tj1tCkNPTkZJR19JUk5FVD1tCkNPTkZJR19JUkNPTU09bQoKQ09ORklHX0lSREFfQ0FDSEVfTEFT
VF9MU0FQPXkKQ09ORklHX0lSREFfRkFTVF9SUj15CgoKQ09ORklHX0lSVFRZX1NJUj1tCgpDT05G
SUdfRE9OR0xFPXkKQ09ORklHX0VTSV9ET05HTEU9bQpDT05GSUdfQUNUSVNZU19ET05HTEU9bQpD
T05GSUdfVEVLUkFNX0RPTkdMRT1tCkNPTkZJR19UT0lNMzIzMl9ET05HTEU9bQpDT05GSUdfTElU
RUxJTktfRE9OR0xFPW0KQ09ORklHX01BNjAwX0RPTkdMRT1tCkNPTkZJR19HSVJCSUxfRE9OR0xF
PW0KQ09ORklHX01DUDIxMjBfRE9OR0xFPW0KQ09ORklHX09MRF9CRUxLSU5fRE9OR0xFPW0KQ09O
RklHX0FDVDIwMExfRE9OR0xFPW0KQ09ORklHX0tJTkdTVU5fRE9OR0xFPW0KQ09ORklHX0tTREFa
WkxFX0RPTkdMRT1tCkNPTkZJR19LUzk1OV9ET05HTEU9bQoKQ09ORklHX1VTQl9JUkRBPW0KQ09O
RklHX1NJR01BVEVMX0ZJUj1tCkNPTkZJR19OU0NfRklSPW0KQ09ORklHX1dJTkJPTkRfRklSPW0K
Q09ORklHX1NNQ19JUkNDX0ZJUj1tCkNPTkZJR19BTElfRklSPW0KQ09ORklHX1ZMU0lfRklSPW0K
Q09ORklHX1ZJQV9GSVI9bQpDT05GSUdfTUNTX0ZJUj1tCkNPTkZJR19CVD1tCkNPTkZJR19CVF9S
RkNPTU09bQpDT05GSUdfQlRfUkZDT01NX1RUWT15CkNPTkZJR19CVF9CTkVQPW0KQ09ORklHX0JU
X0JORVBfTUNfRklMVEVSPXkKQ09ORklHX0JUX0JORVBfUFJPVE9fRklMVEVSPXkKQ09ORklHX0JU
X0NNVFA9bQpDT05GSUdfQlRfSElEUD1tCgpDT05GSUdfQlRfSENJQlRVU0I9bQpDT05GSUdfQlRf
SENJQlRTRElPPW0KQ09ORklHX0JUX0hDSVVBUlQ9bQpDT05GSUdfQlRfSENJVUFSVF9IND15CkNP
TkZJR19CVF9IQ0lVQVJUX0JDU1A9eQpDT05GSUdfQlRfSENJVUFSVF9BVEgzSz15CkNPTkZJR19C
VF9IQ0lVQVJUX0xMPXkKQ09ORklHX0JUX0hDSUJDTTIwM1g9bQpDT05GSUdfQlRfSENJQlBBMTBY
PW0KQ09ORklHX0JUX0hDSUJGVVNCPW0KQ09ORklHX0JUX0hDSURUTDE9bQpDT05GSUdfQlRfSENJ
QlQzQz1tCkNPTkZJR19CVF9IQ0lCTFVFQ0FSRD1tCkNPTkZJR19CVF9IQ0lCVFVBUlQ9bQpDT05G
SUdfQlRfSENJVkhDST1tCkNPTkZJR19CVF9NUlZMPW0KQ09ORklHX0JUX01SVkxfU0RJTz1tCkNP
TkZJR19CVF9BVEgzSz1tCkNPTkZJR19BRl9SWFJQQz1tCkNPTkZJR19SWEtBRD1tCkNPTkZJR19G
SUJfUlVMRVM9eQpDT05GSUdfV0lSRUxFU1M9eQpDT05GSUdfV0lSRUxFU1NfRVhUPXkKQ09ORklH
X1dFWFRfQ09SRT15CkNPTkZJR19XRVhUX1BST0M9eQpDT05GSUdfV0VYVF9TUFk9eQpDT05GSUdf
V0VYVF9QUklWPXkKQ09ORklHX0NGRzgwMjExPW0KQ09ORklHX0NGRzgwMjExX0RFRkFVTFRfUFM9
eQpDT05GSUdfQ0ZHODAyMTFfV0VYVD15CkNPTkZJR19MSUI4MDIxMT1tCkNPTkZJR19MSUI4MDIx
MV9DUllQVF9XRVA9bQpDT05GSUdfTElCODAyMTFfQ1JZUFRfQ0NNUD1tCkNPTkZJR19MSUI4MDIx
MV9DUllQVF9US0lQPW0KQ09ORklHX01BQzgwMjExPW0KQ09ORklHX01BQzgwMjExX0hBU19SQz15
CkNPTkZJR19NQUM4MDIxMV9SQ19NSU5TVFJFTD15CkNPTkZJR19NQUM4MDIxMV9SQ19NSU5TVFJF
TF9IVD15CkNPTkZJR19NQUM4MDIxMV9SQ19ERUZBVUxUX01JTlNUUkVMPXkKQ09ORklHX01BQzgw
MjExX1JDX0RFRkFVTFQ9Im1pbnN0cmVsX2h0IgpDT05GSUdfTUFDODAyMTFfTUVTSD15CkNPTkZJ
R19NQUM4MDIxMV9MRURTPXkKQ09ORklHX1dJTUFYPW0KQ09ORklHX1dJTUFYX0RFQlVHX0xFVkVM
PTgKQ09ORklHX1JGS0lMTD1tCkNPTkZJR19SRktJTExfTEVEUz15CkNPTkZJR19SRktJTExfSU5Q
VVQ9eQpDT05GSUdfTkVUXzlQPW0KQ09ORklHX05FVF85UF9WSVJUSU89bQpDT05GSUdfQ0VQSF9M
SUI9bQpDT05GSUdfTkZDPW0KQ09ORklHX05GQ19OQ0k9bQoKQ09ORklHX05GQ19QTjUzMz1tCkNP
TkZJR19IQVZFX0JQRl9KSVQ9eQoKCkNPTkZJR19VRVZFTlRfSEVMUEVSX1BBVEg9IiIKQ09ORklH
X0RFVlRNUEZTPXkKQ09ORklHX1NUQU5EQUxPTkU9eQpDT05GSUdfUFJFVkVOVF9GSVJNV0FSRV9C
VUlMRD15CkNPTkZJR19GV19MT0FERVI9eQpDT05GSUdfRVhUUkFfRklSTVdBUkU9IiIKQ09ORklH
X1JFR01BUD15CkNPTkZJR19SRUdNQVBfSTJDPW0KQ09ORklHX0RNQV9TSEFSRURfQlVGRkVSPXkK
Q09ORklHX0NPTk5FQ1RPUj1tCkNPTkZJR19NVEQ9bQpDT05GSUdfTVREX1JFREJPT1RfUEFSVFM9
bQpDT05GSUdfTVREX1JFREJPT1RfRElSRUNUT1JZX0JMT0NLPS0xCkNPTkZJR19NVERfQVI3X1BB
UlRTPW0KCkNPTkZJR19NVERfQ0hBUj1tCkNPTkZJR19NVERfQkxLREVWUz1tCkNPTkZJR19NVERf
QkxPQ0s9bQpDT05GSUdfTVREX0JMT0NLX1JPPW0KQ09ORklHX0ZUTD1tCkNPTkZJR19ORlRMPW0K
Q09ORklHX05GVExfUlc9eQpDT05GSUdfSU5GVEw9bQpDT05GSUdfUkZEX0ZUTD1tCkNPTkZJR19T
U0ZEQz1tCkNPTkZJR19NVERfT09QUz1tCkNPTkZJR19NVERfU1dBUD1tCgpDT05GSUdfTVREX0NG
ST1tCkNPTkZJR19NVERfSkVERUNQUk9CRT1tCkNPTkZJR19NVERfR0VOX1BST0JFPW0KQ09ORklH
X01URF9NQVBfQkFOS19XSURUSF8xPXkKQ09ORklHX01URF9NQVBfQkFOS19XSURUSF8yPXkKQ09O
RklHX01URF9NQVBfQkFOS19XSURUSF80PXkKQ09ORklHX01URF9DRklfSTE9eQpDT05GSUdfTVRE
X0NGSV9JMj15CkNPTkZJR19NVERfQ0ZJX0lOVEVMRVhUPW0KQ09ORklHX01URF9DRklfQU1EU1RE
PW0KQ09ORklHX01URF9DRklfU1RBQT1tCkNPTkZJR19NVERfQ0ZJX1VUSUw9bQpDT05GSUdfTVRE
X1JBTT1tCkNPTkZJR19NVERfUk9NPW0KQ09ORklHX01URF9BQlNFTlQ9bQoKQ09ORklHX01URF9D
T01QTEVYX01BUFBJTkdTPXkKQ09ORklHX01URF9QSFlTTUFQPW0KQ09ORklHX01URF9TQzUyMENE
UD1tCkNPTkZJR19NVERfTkVUU0M1MjA9bQpDT05GSUdfTVREX1RTNTUwMD1tCkNPTkZJR19NVERf
U0JDX0dYWD1tCkNPTkZJR19NVERfTkVUdGVsPW0KQ09ORklHX01URF9QQ0k9bQpDT05GSUdfTVRE
X1BDTUNJQT1tCkNPTkZJR19NVERfSU5URUxfVlJfTk9SPW0KQ09ORklHX01URF9QTEFUUkFNPW0K
CkNPTkZJR19NVERfUE1DNTUxPW0KQ09ORklHX01URF9EQVRBRkxBU0g9bQpDT05GSUdfTVREX00y
NVA4MD1tCkNPTkZJR19NMjVQWFhfVVNFX0ZBU1RfUkVBRD15CkNPTkZJR19NVERfU1NUMjVMPW0K
Q09ORklHX01URF9TTFJBTT1tCkNPTkZJR19NVERfUEhSQU09bQpDT05GSUdfTVREX01URFJBTT1t
CkNPTkZJR19NVERSQU1fVE9UQUxfU0laRT00MDk2CkNPTkZJR19NVERSQU1fRVJBU0VfU0laRT0x
MjgKQ09ORklHX01URF9CTE9DSzJNVEQ9bQoKQ09ORklHX01URF9ET0MyMDAwPW0KQ09ORklHX01U
RF9ET0MyMDAxPW0KQ09ORklHX01URF9ET0MyMDAxUExVUz1tCkNPTkZJR19NVERfRE9DUFJPQkU9
bQpDT05GSUdfTVREX0RPQ0VDQz1tCkNPTkZJR19NVERfRE9DUFJPQkVfQUREUkVTUz0weDAKQ09O
RklHX01URF9OQU5EX0VDQz1tCkNPTkZJR19NVERfTkFORD1tCkNPTkZJR19NVERfU01fQ09NTU9O
PW0KQ09ORklHX01URF9OQU5EX0lEUz1tCkNPTkZJR19NVERfTkFORF9SSUNPSD1tCkNPTkZJR19N
VERfTkFORF9ESVNLT05DSElQPW0KQ09ORklHX01URF9OQU5EX0RJU0tPTkNISVBfUFJPQkVfQURE
UkVTUz0wCkNPTkZJR19NVERfTkFORF9DQUZFPW0KQ09ORklHX01URF9OQU5EX05BTkRTSU09bQpD
T05GSUdfTVREX05BTkRfUExBVEZPUk09bQpDT05GSUdfTVREX0FMQVVEQT1tCkNPTkZJR19NVERf
T05FTkFORD1tCkNPTkZJR19NVERfT05FTkFORF9WRVJJRllfV1JJVEU9eQpDT05GSUdfTVREX09O
RU5BTkRfR0VORVJJQz1tCkNPTkZJR19NVERfT05FTkFORF8yWF9QUk9HUkFNPXkKQ09ORklHX01U
RF9PTkVOQU5EX1NJTT1tCgpDT05GSUdfTVREX0xQRERSPW0KQ09ORklHX01URF9RSU5GT19QUk9C
RT1tCkNPTkZJR19NVERfVUJJPW0KQ09ORklHX01URF9VQklfV0xfVEhSRVNIT0xEPTQwOTYKQ09O
RklHX01URF9VQklfQkVCX1JFU0VSVkU9MQpDT05GSUdfUEFSUE9SVD1tCkNPTkZJR19QQVJQT1JU
X1BDPW0KQ09ORklHX1BBUlBPUlRfU0VSSUFMPW0KQ09ORklHX1BBUlBPUlRfUENfUENNQ0lBPW0K
Q09ORklHX1BBUlBPUlRfQVg4ODc5Nj1tCkNPTkZJR19QQVJQT1JUXzEyODQ9eQpDT05GSUdfUEFS
UE9SVF9OT1RfUEM9eQpDT05GSUdfUE5QPXkKCkNPTkZJR19QTlBBQ1BJPXkKQ09ORklHX0JMS19E
RVY9eQpDT05GSUdfQkxLX0RFVl9GRD1tCkNPTkZJR19QQVJJREU9bQoKQ09ORklHX1BBUklERV9Q
RD1tCkNPTkZJR19QQVJJREVfUENEPW0KQ09ORklHX1BBUklERV9QRj1tCkNPTkZJR19QQVJJREVf
UFQ9bQpDT05GSUdfUEFSSURFX1BHPW0KCkNPTkZJR19QQVJJREVfQVRFTj1tCkNPTkZJR19QQVJJ
REVfQlBDSz1tCkNPTkZJR19QQVJJREVfQ09NTT1tCkNPTkZJR19QQVJJREVfRFNUUj1tCkNPTkZJ
R19QQVJJREVfRklUMj1tCkNPTkZJR19QQVJJREVfRklUMz1tCkNPTkZJR19QQVJJREVfRVBBVD1t
CkNPTkZJR19QQVJJREVfRVBJQT1tCkNPTkZJR19QQVJJREVfRlJJUT1tCkNPTkZJR19QQVJJREVf
RlJQVz1tCkNPTkZJR19QQVJJREVfS0JJQz1tCkNPTkZJR19QQVJJREVfS1RUST1tCkNPTkZJR19Q
QVJJREVfT04yMD1tCkNPTkZJR19QQVJJREVfT04yNj1tCkNPTkZJR19CTEtfQ1BRX0RBPW0KQ09O
RklHX0JMS19DUFFfQ0lTU19EQT1tCkNPTkZJR19DSVNTX1NDU0lfVEFQRT15CkNPTkZJR19CTEtf
REVWX0RBQzk2MD1tCkNPTkZJR19CTEtfREVWX1VNRU09bQpDT05GSUdfQkxLX0RFVl9MT09QPW0K
Q09ORklHX0JMS19ERVZfTE9PUF9NSU5fQ09VTlQ9OApDT05GSUdfQkxLX0RFVl9EUkJEPW0KQ09O
RklHX0JMS19ERVZfTkJEPW0KQ09ORklHX0JMS19ERVZfT1NEPW0KQ09ORklHX0JMS19ERVZfU1g4
PW0KQ09ORklHX0JMS19ERVZfUkFNPW0KQ09ORklHX0JMS19ERVZfUkFNX0NPVU5UPTE2CkNPTkZJ
R19CTEtfREVWX1JBTV9TSVpFPTY1NTM2CkNPTkZJR19DRFJPTV9QS1RDRFZEPW0KQ09ORklHX0NE
Uk9NX1BLVENEVkRfQlVGRkVSUz04CkNPTkZJR19BVEFfT1ZFUl9FVEg9bQpDT05GSUdfVklSVElP
X0JMSz1tCkNPTkZJR19CTEtfREVWX1JCRD1tCgpDT05GSUdfU0VOU09SU19MSVMzTFYwMkQ9bQpD
T05GSUdfQUQ1MjVYX0RQT1Q9bQpDT05GSUdfQUQ1MjVYX0RQT1RfSTJDPW0KQ09ORklHX0FENTI1
WF9EUE9UX1NQST1tCkNPTkZJR19JQk1fQVNNPW0KQ09ORklHX1BIQU5UT009bQpDT05GSUdfU0dJ
X0lPQzQ9bQpDT05GSUdfVElGTV9DT1JFPW0KQ09ORklHX1RJRk1fN1hYMT1tCkNPTkZJR19JQ1M5
MzJTNDAxPW0KQ09ORklHX0VOQ0xPU1VSRV9TRVJWSUNFUz1tCkNPTkZJR19IUF9JTE89bQpDT05G
SUdfQVBEUzk4MDJBTFM9bQpDT05GSUdfSVNMMjkwMDM9bQpDT05GSUdfSVNMMjkwMjA9bQpDT05G
SUdfU0VOU09SU19UU0wyNTUwPW0KQ09ORklHX1NFTlNPUlNfQkgxNzgwPW0KQ09ORklHX1NFTlNP
UlNfQkgxNzcwPW0KQ09ORklHX1NFTlNPUlNfQVBEUzk5MFg9bQpDT05GSUdfSE1DNjM1Mj1tCkNP
TkZJR19EUzE2ODI9bQpDT05GSUdfVElfREFDNzUxMj1tCkNPTkZJR19WTVdBUkVfQkFMTE9PTj1t
CkNPTkZJR19QQ0hfUEhVQj1tCkNPTkZJR19DMlBPUlQ9bQpDT05GSUdfQzJQT1JUX0RVUkFNQVJf
MjE1MD1tCgpDT05GSUdfRUVQUk9NX0FUMjQ9bQpDT05GSUdfRUVQUk9NX0FUMjU9bQpDT05GSUdf
RUVQUk9NX0xFR0FDWT1tCkNPTkZJR19FRVBST01fTUFYNjg3NT1tCkNPTkZJR19FRVBST01fOTND
WDY9bQpDT05GSUdfQ0I3MTBfQ09SRT1tCkNPTkZJR19DQjcxMF9ERUJVR19BU1NVTVBUSU9OUz15
CgpDT05GSUdfU0VOU09SU19MSVMzX0kyQz1tCgpDT05GSUdfSEFWRV9JREU9eQoKQ09ORklHX1ND
U0lfTU9EPW0KQ09ORklHX1JBSURfQVRUUlM9bQpDT05GSUdfU0NTST1tCkNPTkZJR19TQ1NJX0RN
QT15CkNPTkZJR19TQ1NJX1RHVD1tCkNPTkZJR19TQ1NJX05FVExJTks9eQoKQ09ORklHX0JMS19E
RVZfU0Q9bQpDT05GSUdfQ0hSX0RFVl9TVD1tCkNPTkZJR19DSFJfREVWX09TU1Q9bQpDT05GSUdf
QkxLX0RFVl9TUj1tCkNPTkZJR19CTEtfREVWX1NSX1ZFTkRPUj15CkNPTkZJR19DSFJfREVWX1NH
PW0KQ09ORklHX0NIUl9ERVZfU0NIPW0KQ09ORklHX1NDU0lfRU5DTE9TVVJFPW0KQ09ORklHX1ND
U0lfTVVMVElfTFVOPXkKQ09ORklHX1NDU0lfQ09OU1RBTlRTPXkKQ09ORklHX1NDU0lfTE9HR0lO
Rz15CkNPTkZJR19TQ1NJX1NDQU5fQVNZTkM9eQoKQ09ORklHX1NDU0lfU1BJX0FUVFJTPW0KQ09O
RklHX1NDU0lfRkNfQVRUUlM9bQpDT05GSUdfU0NTSV9GQ19UR1RfQVRUUlM9eQpDT05GSUdfU0NT
SV9JU0NTSV9BVFRSUz1tCkNPTkZJR19TQ1NJX1NBU19BVFRSUz1tCkNPTkZJR19TQ1NJX1NBU19M
SUJTQVM9bQpDT05GSUdfU0NTSV9TQVNfQVRBPXkKQ09ORklHX1NDU0lfU0FTX0hPU1RfU01QPXkK
Q09ORklHX1NDU0lfU1JQX0FUVFJTPW0KQ09ORklHX1NDU0lfU1JQX1RHVF9BVFRSUz15CkNPTkZJ
R19TQ1NJX0xPV0xFVkVMPXkKQ09ORklHX0lTQ1NJX1RDUD1tCkNPTkZJR19JU0NTSV9CT09UX1NZ
U0ZTPW0KQ09ORklHX1NDU0lfQ1hHQjNfSVNDU0k9bQpDT05GSUdfU0NTSV9DWEdCNF9JU0NTST1t
CkNPTkZJR19TQ1NJX0JOWDJfSVNDU0k9bQpDT05GSUdfU0NTSV9CTlgyWF9GQ09FPW0KQ09ORklH
X0JFMklTQ1NJPW0KQ09ORklHX0JMS19ERVZfM1dfWFhYWF9SQUlEPW0KQ09ORklHX1NDU0lfSFBT
QT1tCkNPTkZJR19TQ1NJXzNXXzlYWFg9bQpDT05GSUdfU0NTSV8zV19TQVM9bQpDT05GSUdfU0NT
SV9BQ0FSRD1tCkNPTkZJR19TQ1NJX0FBQ1JBSUQ9bQpDT05GSUdfU0NTSV9BSUM3WFhYPW0KQ09O
RklHX0FJQzdYWFhfQ01EU19QRVJfREVWSUNFPTgKQ09ORklHX0FJQzdYWFhfUkVTRVRfREVMQVlf
TVM9MTUwMDAKQ09ORklHX0FJQzdYWFhfREVCVUdfRU5BQkxFPXkKQ09ORklHX0FJQzdYWFhfREVC
VUdfTUFTSz0wCkNPTkZJR19BSUM3WFhYX1JFR19QUkVUVFlfUFJJTlQ9eQpDT05GSUdfU0NTSV9B
SUM3WFhYX09MRD1tCkNPTkZJR19TQ1NJX0FJQzc5WFg9bQpDT05GSUdfQUlDNzlYWF9DTURTX1BF
Ul9ERVZJQ0U9MzIKQ09ORklHX0FJQzc5WFhfUkVTRVRfREVMQVlfTVM9MTUwMDAKQ09ORklHX0FJ
Qzc5WFhfREVCVUdfRU5BQkxFPXkKQ09ORklHX0FJQzc5WFhfREVCVUdfTUFTSz0wCkNPTkZJR19B
SUM3OVhYX1JFR19QUkVUVFlfUFJJTlQ9eQpDT05GSUdfU0NTSV9BSUM5NFhYPW0KQ09ORklHX1ND
U0lfTVZTQVM9bQpDT05GSUdfU0NTSV9NVlVNST1tCkNPTkZJR19TQ1NJX0RQVF9JMk89bQpDT05G
SUdfU0NTSV9BRFZBTlNZUz1tCkNPTkZJR19TQ1NJX0FSQ01TUj1tCkNPTkZJR19NRUdBUkFJRF9O
RVdHRU49eQpDT05GSUdfTUVHQVJBSURfTU09bQpDT05GSUdfTUVHQVJBSURfTUFJTEJPWD1tCkNP
TkZJR19NRUdBUkFJRF9MRUdBQ1k9bQpDT05GSUdfTUVHQVJBSURfU0FTPW0KQ09ORklHX1NDU0lf
TVBUMlNBUz1tCkNPTkZJR19TQ1NJX01QVDJTQVNfTUFYX1NHRT0xMjgKQ09ORklHX1NDU0lfSFBU
SU9QPW0KQ09ORklHX1NDU0lfQlVTTE9HSUM9bQpDT05GSUdfVk1XQVJFX1BWU0NTST1tCkNPTkZJ
R19IWVBFUlZfU1RPUkFHRT1tCkNPTkZJR19MSUJGQz1tCkNPTkZJR19MSUJGQ09FPW0KQ09ORklH
X0ZDT0U9bQpDT05GSUdfRkNPRV9GTklDPW0KQ09ORklHX1NDU0lfRE1YMzE5MUQ9bQpDT05GSUdf
U0NTSV9FQVRBPW0KQ09ORklHX1NDU0lfRUFUQV9UQUdHRURfUVVFVUU9eQpDT05GSUdfU0NTSV9F
QVRBX0xJTktFRF9DT01NQU5EUz15CkNPTkZJR19TQ1NJX0VBVEFfTUFYX1RBR1M9MTYKQ09ORklH
X1NDU0lfRlVUVVJFX0RPTUFJTj1tCkNPTkZJR19TQ1NJX0dEVEg9bQpDT05GSUdfU0NTSV9JU0NJ
PW0KQ09ORklHX1NDU0lfSVBTPW0KQ09ORklHX1NDU0lfSU5JVElPPW0KQ09ORklHX1NDU0lfSU5J
QTEwMD1tCkNPTkZJR19TQ1NJX1BQQT1tCkNPTkZJR19TQ1NJX0lNTT1tCkNPTkZJR19TQ1NJX1NU
RVg9bQpDT05GSUdfU0NTSV9TWU01M0M4WFhfMj1tCkNPTkZJR19TQ1NJX1NZTTUzQzhYWF9ETUFf
QUREUkVTU0lOR19NT0RFPTEKQ09ORklHX1NDU0lfU1lNNTNDOFhYX0RFRkFVTFRfVEFHUz0xNgpD
T05GSUdfU0NTSV9TWU01M0M4WFhfTUFYX1RBR1M9NjQKQ09ORklHX1NDU0lfU1lNNTNDOFhYX01N
SU89eQpDT05GSUdfU0NTSV9JUFI9bQpDT05GSUdfU0NTSV9RTE9HSUNfMTI4MD1tCkNPTkZJR19T
Q1NJX1FMQV9GQz1tCkNPTkZJR19TQ1NJX1FMQV9JU0NTST1tCkNPTkZJR19TQ1NJX0xQRkM9bQpD
T05GSUdfU0NTSV9EQzM5NXg9bQpDT05GSUdfU0NTSV9EQzM5MFQ9bQpDT05GSUdfU0NTSV9ERUJV
Rz1tCkNPTkZJR19TQ1NJX1BNQ1JBSUQ9bQpDT05GSUdfU0NTSV9QTTgwMDE9bQpDT05GSUdfU0NT
SV9TUlA9bQpDT05GSUdfU0NTSV9CRkFfRkM9bQpDT05GSUdfU0NTSV9MT1dMRVZFTF9QQ01DSUE9
eQpDT05GSUdfUENNQ0lBX0FIQTE1Mlg9bQpDT05GSUdfUENNQ0lBX0ZET01BSU49bQpDT05GSUdf
UENNQ0lBX1FMT0dJQz1tCkNPTkZJR19QQ01DSUFfU1lNNTNDNTAwPW0KQ09ORklHX1NDU0lfREg9
bQpDT05GSUdfU0NTSV9ESF9SREFDPW0KQ09ORklHX1NDU0lfREhfSFBfU1c9bQpDT05GSUdfU0NT
SV9ESF9FTUM9bQpDT05GSUdfU0NTSV9ESF9BTFVBPW0KQ09ORklHX1NDU0lfT1NEX0lOSVRJQVRP
Uj1tCkNPTkZJR19TQ1NJX09TRF9VTEQ9bQpDT05GSUdfU0NTSV9PU0RfRFBSSU5UX1NFTlNFPTEK
Q09ORklHX0FUQT1tCkNPTkZJR19BVEFfVkVSQk9TRV9FUlJPUj15CkNPTkZJR19BVEFfQUNQST15
CkNPTkZJR19TQVRBX1BNUD15CgpDT05GSUdfU0FUQV9BSENJPW0KQ09ORklHX1NBVEFfSU5JQzE2
Mlg9bQpDT05GSUdfU0FUQV9BQ0FSRF9BSENJPW0KQ09ORklHX1NBVEFfU0lMMjQ9bQpDT05GSUdf
QVRBX1NGRj15CgpDT05GSUdfUERDX0FETUE9bQpDT05GSUdfU0FUQV9RU1RPUj1tCkNPTkZJR19T
QVRBX1NYND1tCkNPTkZJR19BVEFfQk1ETUE9eQoKQ09ORklHX0FUQV9QSUlYPW0KQ09ORklHX1NB
VEFfTVY9bQpDT05GSUdfU0FUQV9OVj1tCkNPTkZJR19TQVRBX1BST01JU0U9bQpDT05GSUdfU0FU
QV9TSUw9bQpDT05GSUdfU0FUQV9TSVM9bQpDT05GSUdfU0FUQV9TVlc9bQpDT05GSUdfU0FUQV9V
TEk9bQpDT05GSUdfU0FUQV9WSUE9bQpDT05GSUdfU0FUQV9WSVRFU1NFPW0KCkNPTkZJR19QQVRB
X0FMST1tCkNPTkZJR19QQVRBX0FNRD1tCkNPTkZJR19QQVRBX0FSQVNBTl9DRj1tCkNPTkZJR19Q
QVRBX0FSVE9QPW0KQ09ORklHX1BBVEFfQVRJSVhQPW0KQ09ORklHX1BBVEFfQVRQODY3WD1tCkNP
TkZJR19QQVRBX0NNRDY0WD1tCkNPTkZJR19QQVRBX0NTNTUyMD1tCkNPTkZJR19QQVRBX0NTNTUz
MD1tCkNPTkZJR19QQVRBX0VGQVI9bQpDT05GSUdfUEFUQV9IUFQzNjY9bQpDT05GSUdfUEFUQV9I
UFQzN1g9bQpDT05GSUdfUEFUQV9JVDgyMTM9bQpDT05GSUdfUEFUQV9JVDgyMVg9bQpDT05GSUdf
UEFUQV9KTUlDUk9OPW0KQ09ORklHX1BBVEFfTUFSVkVMTD1tCkNPTkZJR19QQVRBX05FVENFTEw9
bQpDT05GSUdfUEFUQV9OSU5KQTMyPW0KQ09ORklHX1BBVEFfTlM4NzQxNT1tCkNPTkZJR19QQVRB
X09MRFBJSVg9bQpDT05GSUdfUEFUQV9QREMyMDI3WD1tCkNPTkZJR19QQVRBX1BEQ19PTEQ9bQpD
T05GSUdfUEFUQV9SREM9bQpDT05GSUdfUEFUQV9TQzEyMDA9bQpDT05GSUdfUEFUQV9TQ0g9bQpD
T05GSUdfUEFUQV9TRVJWRVJXT1JLUz1tCkNPTkZJR19QQVRBX1NJTDY4MD1tCkNPTkZJR19QQVRB
X1NJUz1tCkNPTkZJR19QQVRBX1RPU0hJQkE9bQpDT05GSUdfUEFUQV9UUklGTEVYPW0KQ09ORklH
X1BBVEFfVklBPW0KCkNPTkZJR19QQVRBX01QSUlYPW0KQ09ORklHX1BBVEFfTlM4NzQxMD1tCkNP
TkZJR19QQVRBX1BDTUNJQT1tCkNPTkZJR19QQVRBX1JaMTAwMD1tCgpDT05GSUdfQVRBX0dFTkVS
SUM9bQpDT05GSUdfTUQ9eQpDT05GSUdfQkxLX0RFVl9NRD1tCkNPTkZJR19NRF9MSU5FQVI9bQpD
T05GSUdfTURfUkFJRDA9bQpDT05GSUdfTURfUkFJRDE9bQpDT05GSUdfTURfUkFJRDEwPW0KQ09O
RklHX01EX1JBSUQ0NTY9bQpDT05GSUdfTURfTVVMVElQQVRIPW0KQ09ORklHX01EX0ZBVUxUWT1t
CkNPTkZJR19CTEtfREVWX0RNPW0KQ09ORklHX0RNX0JVRklPPW0KQ09ORklHX0RNX1BFUlNJU1RF
TlRfREFUQT1tCkNPTkZJR19ETV9DUllQVD1tCkNPTkZJR19ETV9TTkFQU0hPVD1tCkNPTkZJR19E
TV9USElOX1BST1ZJU0lPTklORz1tCkNPTkZJR19ETV9NSVJST1I9bQpDT05GSUdfRE1fUkFJRD1t
CkNPTkZJR19ETV9MT0dfVVNFUlNQQUNFPW0KQ09ORklHX0RNX1pFUk89bQpDT05GSUdfRE1fTVVM
VElQQVRIPW0KQ09ORklHX0RNX01VTFRJUEFUSF9RTD1tCkNPTkZJR19ETV9NVUxUSVBBVEhfU1Q9
bQpDT05GSUdfRE1fREVMQVk9bQpDT05GSUdfRE1fVUVWRU5UPXkKQ09ORklHX0RNX0ZMQUtFWT1t
CkNPTkZJR19UQVJHRVRfQ09SRT1tCkNPTkZJR19UQ01fSUJMT0NLPW0KQ09ORklHX1RDTV9GSUxF
SU89bQpDT05GSUdfVENNX1BTQ1NJPW0KQ09ORklHX0xPT1BCQUNLX1RBUkdFVD1tCkNPTkZJR19U
Q01fRkM9bQpDT05GSUdfSVNDU0lfVEFSR0VUPW0KQ09ORklHX0ZVU0lPTj15CkNPTkZJR19GVVNJ
T05fU1BJPW0KQ09ORklHX0ZVU0lPTl9GQz1tCkNPTkZJR19GVVNJT05fU0FTPW0KQ09ORklHX0ZV
U0lPTl9NQVhfU0dFPTEyOApDT05GSUdfRlVTSU9OX0NUTD1tCkNPTkZJR19GVVNJT05fTEFOPW0K
CkNPTkZJR19GSVJFV0lSRT1tCkNPTkZJR19GSVJFV0lSRV9PSENJPW0KQ09ORklHX0ZJUkVXSVJF
X1NCUDI9bQpDT05GSUdfRklSRVdJUkVfTkVUPW0KQ09ORklHX0ZJUkVXSVJFX05PU1k9bQpDT05G
SUdfSTJPPW0KQ09ORklHX0kyT19MQ1RfTk9USUZZX09OX0NIQU5HRVM9eQpDT05GSUdfSTJPX0VY
VF9BREFQVEVDPXkKQ09ORklHX0kyT19FWFRfQURBUFRFQ19ETUE2ND15CkNPTkZJR19JMk9fQ09O
RklHPW0KQ09ORklHX0kyT19DT05GSUdfT0xEX0lPQ1RMPXkKQ09ORklHX0kyT19CVVM9bQpDT05G
SUdfSTJPX0JMT0NLPW0KQ09ORklHX0kyT19TQ1NJPW0KQ09ORklHX0kyT19QUk9DPW0KQ09ORklH
X01BQ0lOVE9TSF9EUklWRVJTPXkKQ09ORklHX01BQ19FTVVNT1VTRUJUTj15CkNPTkZJR19ORVRE
RVZJQ0VTPXkKQ09ORklHX05FVF9DT1JFPXkKQ09ORklHX0JPTkRJTkc9bQpDT05GSUdfRFVNTVk9
bQpDT05GSUdfRVFVQUxJWkVSPW0KQ09ORklHX05FVF9GQz15CkNPTkZJR19NSUk9bQpDT05GSUdf
SUVFRTgwMjE1NF9EUklWRVJTPW0KQ09ORklHX0lFRUU4MDIxNTRfRkFLRUhBUkQ9bQpDT05GSUdf
SUZCPW0KQ09ORklHX01BQ1ZMQU49bQpDT05GSUdfTUFDVlRBUD1tCkNPTkZJR19ORVRDT05TT0xF
PW0KQ09ORklHX05FVENPTlNPTEVfRFlOQU1JQz15CkNPTkZJR19ORVRQT0xMPXkKQ09ORklHX05F
VF9QT0xMX0NPTlRST0xMRVI9eQpDT05GSUdfVFVOPW0KQ09ORklHX1ZFVEg9bQpDT05GSUdfVklS
VElPX05FVD1tCkNPTkZJR19TVU5HRU1fUEhZPW0KQ09ORklHX0FSQ05FVD1tCkNPTkZJR19BUkNO
RVRfMTIwMT1tCkNPTkZJR19BUkNORVRfMTA1MT1tCkNPTkZJR19BUkNORVRfUkFXPW0KQ09ORklH
X0FSQ05FVF9DQVA9bQpDT05GSUdfQVJDTkVUX0NPTTkweHg9bQpDT05GSUdfQVJDTkVUX0NPTTkw
eHhJTz1tCkNPTkZJR19BUkNORVRfUklNX0k9bQpDT05GSUdfQVJDTkVUX0NPTTIwMDIwPW0KQ09O
RklHX0FSQ05FVF9DT00yMDAyMF9QQ0k9bQpDT05GSUdfQVJDTkVUX0NPTTIwMDIwX0NTPW0KQ09O
RklHX0FUTV9EUklWRVJTPXkKQ09ORklHX0FUTV9EVU1NWT1tCkNPTkZJR19BVE1fVENQPW0KQ09O
RklHX0FUTV9MQU5BST1tCkNPTkZJR19BVE1fRU5JPW0KQ09ORklHX0FUTV9GSVJFU1RSRUFNPW0K
Q09ORklHX0FUTV9aQVRNPW0KQ09ORklHX0FUTV9OSUNTVEFSPW0KQ09ORklHX0FUTV9OSUNTVEFS
X1VTRV9TVU5JPXkKQ09ORklHX0FUTV9OSUNTVEFSX1VTRV9JRFQ3NzEwNT15CkNPTkZJR19BVE1f
SURUNzcyNTI9bQpDT05GSUdfQVRNX0lEVDc3MjUyX1VTRV9TVU5JPXkKQ09ORklHX0FUTV9BTUJB
U1NBRE9SPW0KQ09ORklHX0FUTV9IT1JJWk9OPW0KQ09ORklHX0FUTV9JQT1tCkNPTkZJR19BVE1f
Rk9SRTIwMEU9bQpDT05GSUdfQVRNX0ZPUkUyMDBFX1RYX1JFVFJZPTE2CkNPTkZJR19BVE1fRk9S
RTIwMEVfREVCVUc9MApDT05GSUdfQVRNX0hFPW0KQ09ORklHX0FUTV9IRV9VU0VfU1VOST15CkNP
TkZJR19BVE1fU09MT1M9bQoKQ09ORklHX0VUSEVSTkVUPXkKQ09ORklHX01ESU89bQpDT05GSUdf
TkVUX1ZFTkRPUl8zQ09NPXkKQ09ORklHX1BDTUNJQV8zQzU3ND1tCkNPTkZJR19QQ01DSUFfM0M1
ODk9bQpDT05GSUdfVk9SVEVYPW0KQ09ORklHX1RZUEhPT049bQpDT05GSUdfTkVUX1ZFTkRPUl9B
REFQVEVDPXkKQ09ORklHX0FEQVBURUNfU1RBUkZJUkU9bQpDT05GSUdfTkVUX1ZFTkRPUl9BTFRF
T049eQpDT05GSUdfQUNFTklDPW0KQ09ORklHX05FVF9WRU5ET1JfQU1EPXkKQ09ORklHX0FNRDgx
MTFfRVRIPW0KQ09ORklHX1BDTkVUMzI9bQpDT05GSUdfUENNQ0lBX05NQ0xBTj1tCkNPTkZJR19O
RVRfVkVORE9SX0FUSEVST1M9eQpDT05GSUdfQVRMMj1tCkNPTkZJR19BVEwxPW0KQ09ORklHX0FU
TDFFPW0KQ09ORklHX0FUTDFDPW0KQ09ORklHX05FVF9WRU5ET1JfQlJPQURDT009eQpDT05GSUdf
QjQ0PW0KQ09ORklHX0I0NF9QQ0lfQVVUT1NFTEVDVD15CkNPTkZJR19CNDRfUENJQ09SRV9BVVRP
U0VMRUNUPXkKQ09ORklHX0I0NF9QQ0k9eQpDT05GSUdfQk5YMj1tCkNPTkZJR19DTklDPW0KQ09O
RklHX1RJR09OMz1tCkNPTkZJR19CTlgyWD1tCkNPTkZJR19ORVRfVkVORE9SX0JST0NBREU9eQpD
T05GSUdfQk5BPW0KQ09ORklHX05FVF9WRU5ET1JfQ0hFTFNJTz15CkNPTkZJR19DSEVMU0lPX1Qx
PW0KQ09ORklHX0NIRUxTSU9fVDFfMUc9eQpDT05GSUdfQ0hFTFNJT19UMz1tCkNPTkZJR19DSEVM
U0lPX1Q0PW0KQ09ORklHX0NIRUxTSU9fVDRWRj1tCkNPTkZJR19ORVRfVkVORE9SX0NJU0NPPXkK
Q09ORklHX0VOSUM9bQpDT05GSUdfRE5FVD1tCkNPTkZJR19ORVRfVkVORE9SX0RFQz15CkNPTkZJ
R19ORVRfVFVMSVA9eQpDT05GSUdfREUyMTA0WD1tCkNPTkZJR19ERTIxMDRYX0RTTD0wCkNPTkZJ
R19UVUxJUD1tCkNPTkZJR19UVUxJUF9OQVBJPXkKQ09ORklHX1RVTElQX05BUElfSFdfTUlUSUdB
VElPTj15CkNPTkZJR19XSU5CT05EXzg0MD1tCkNPTkZJR19ETTkxMDI9bQpDT05GSUdfVUxJNTI2
WD1tCkNPTkZJR19QQ01DSUFfWElSQ09NPW0KQ09ORklHX05FVF9WRU5ET1JfRExJTks9eQpDT05G
SUdfREU2MDA9bQpDT05GSUdfREU2MjA9bQpDT05GSUdfREwySz1tCkNPTkZJR19TVU5EQU5DRT1t
CkNPTkZJR19ORVRfVkVORE9SX0VNVUxFWD15CkNPTkZJR19CRTJORVQ9bQpDT05GSUdfTkVUX1ZF
TkRPUl9FWEFSPXkKQ09ORklHX1MySU89bQpDT05GSUdfVlhHRT1tCkNPTkZJR19ORVRfVkVORE9S
X0ZVSklUU1U9eQpDT05GSUdfUENNQ0lBX0ZNVkoxOFg9bQpDT05GSUdfTkVUX1ZFTkRPUl9IUD15
CkNPTkZJR19IUDEwMD1tCkNPTkZJR19ORVRfVkVORE9SX0lOVEVMPXkKQ09ORklHX0UxMDA9bQpD
T05GSUdfRTEwMDA9bQpDT05GSUdfRTEwMDBFPW0KQ09ORklHX0lHQj1tCkNPTkZJR19JR0JfRENB
PXkKQ09ORklHX0lHQlZGPW0KQ09ORklHX0lYR0I9bQpDT05GSUdfSVhHQkU9bQpDT05GSUdfSVhH
QkVfSFdNT049eQpDT05GSUdfSVhHQkVfRENBPXkKQ09ORklHX0lYR0JFX0RDQj15CkNPTkZJR19J
WEdCRVZGPW0KQ09ORklHX05FVF9WRU5ET1JfSTgyNVhYPXkKQ09ORklHX0lQMTAwMD1tCkNPTkZJ
R19KTUU9bQpDT05GSUdfTkVUX1ZFTkRPUl9NQVJWRUxMPXkKQ09ORklHX1NLR0U9bQpDT05GSUdf
U0tHRV9HRU5FU0lTPXkKQ09ORklHX1NLWTI9bQpDT05GSUdfTkVUX1ZFTkRPUl9NRUxMQU5PWD15
CkNPTkZJR19NTFg0X0VOPW0KQ09ORklHX01MWDRfRU5fRENCPXkKQ09ORklHX01MWDRfQ09SRT1t
CkNPTkZJR19NTFg0X0RFQlVHPXkKQ09ORklHX05FVF9WRU5ET1JfTUlDUkVMPXkKQ09ORklHX0tT
ODg0Mj1tCkNPTkZJR19LUzg4NTE9bQpDT05GSUdfS1M4ODUxX01MTD1tCkNPTkZJR19LU1o4ODRY
X1BDST1tCkNPTkZJR19ORVRfVkVORE9SX01JQ1JPQ0hJUD15CkNPTkZJR19FTkMyOEo2MD1tCkNP
TkZJR19ORVRfVkVORE9SX01ZUkk9eQpDT05GSUdfTVlSSTEwR0U9bQpDT05GSUdfTVlSSTEwR0Vf
RENBPXkKQ09ORklHX0ZFQUxOWD1tCkNPTkZJR19ORVRfVkVORE9SX05BVFNFTUk9eQpDT05GSUdf
TkFUU0VNST1tCkNPTkZJR19OUzgzODIwPW0KQ09ORklHX05FVF9WRU5ET1JfODM5MD15CkNPTkZJ
R19QQ01DSUFfQVhORVQ9bQpDT05GSUdfTkUyS19QQ0k9bQpDT05GSUdfUENNQ0lBX1BDTkVUPW0K
Q09ORklHX05FVF9WRU5ET1JfTlZJRElBPXkKQ09ORklHX0ZPUkNFREVUSD1tCkNPTkZJR19ORVRf
VkVORE9SX09LST15CkNPTkZJR19QQ0hfR0JFPW0KQ09ORklHX0VUSE9DPW0KQ09ORklHX05FVF9Q
QUNLRVRfRU5HSU5FPXkKQ09ORklHX0hBTUFDSEk9bQpDT05GSUdfWUVMTE9XRklOPW0KQ09ORklH
X05FVF9WRU5ET1JfUUxPR0lDPXkKQ09ORklHX1FMQTNYWFg9bQpDT05GSUdfUUxDTklDPW0KQ09O
RklHX1FMR0U9bQpDT05GSUdfTkVUWEVOX05JQz1tCkNPTkZJR19ORVRfVkVORE9SX1JFQUxURUs9
eQpDT05GSUdfQVRQPW0KQ09ORklHXzgxMzlDUD1tCkNPTkZJR184MTM5VE9PPW0KQ09ORklHXzgx
MzlUT09fVFVORV9UV0lTVEVSPXkKQ09ORklHXzgxMzlUT09fODEyOT15CkNPTkZJR19SODE2OT1t
CkNPTkZJR19ORVRfVkVORE9SX1JEQz15CkNPTkZJR19SNjA0MD1tCkNPTkZJR19ORVRfVkVORE9S
X1NFRVE9eQpDT05GSUdfTkVUX1ZFTkRPUl9TSUxBTj15CkNPTkZJR19TQzkyMDMxPW0KQ09ORklH
X05FVF9WRU5ET1JfU0lTPXkKQ09ORklHX1NJUzkwMD1tCkNPTkZJR19TSVMxOTA9bQpDT05GSUdf
U0ZDPW0KQ09ORklHX1NGQ19NVEQ9eQpDT05GSUdfU0ZDX01DRElfTU9OPXkKQ09ORklHX1NGQ19T
UklPVj15CkNPTkZJR19ORVRfVkVORE9SX1NNU0M9eQpDT05GSUdfUENNQ0lBX1NNQzkxQzkyPW0K
Q09ORklHX0VQSUMxMDA9bQpDT05GSUdfU01TQzk0MjA9bQpDT05GSUdfTkVUX1ZFTkRPUl9TVE1J
Q1JPPXkKQ09ORklHX05FVF9WRU5ET1JfU1VOPXkKQ09ORklHX0hBUFBZTUVBTD1tCkNPTkZJR19T
VU5HRU09bQpDT05GSUdfQ0FTU0lOST1tCkNPTkZJR19OSVU9bQpDT05GSUdfTkVUX1ZFTkRPUl9U
RUhVVEk9eQpDT05GSUdfVEVIVVRJPW0KQ09ORklHX05FVF9WRU5ET1JfVEk9eQpDT05GSUdfVExB
Tj1tCkNPTkZJR19ORVRfVkVORE9SX1ZJQT15CkNPTkZJR19WSUFfUkhJTkU9bQpDT05GSUdfVklB
X1ZFTE9DSVRZPW0KQ09ORklHX05FVF9WRU5ET1JfV0laTkVUPXkKQ09ORklHX05FVF9WRU5ET1Jf
WElSQ09NPXkKQ09ORklHX1BDTUNJQV9YSVJDMlBTPW0KQ09ORklHX0ZEREk9eQpDT05GSUdfREVG
WFg9bQpDT05GSUdfU0tGUD1tCkNPTkZJR19ISVBQST15CkNPTkZJR19ST0FEUlVOTkVSPW0KQ09O
RklHX05FVF9TQjEwMDA9bQpDT05GSUdfUEhZTElCPW0KCkNPTkZJR19NQVJWRUxMX1BIWT1tCkNP
TkZJR19EQVZJQ09NX1BIWT1tCkNPTkZJR19RU0VNSV9QSFk9bQpDT05GSUdfTFhUX1BIWT1tCkNP
TkZJR19DSUNBREFfUEhZPW0KQ09ORklHX1ZJVEVTU0VfUEhZPW0KQ09ORklHX1NNU0NfUEhZPW0K
Q09ORklHX0JST0FEQ09NX1BIWT1tCkNPTkZJR19JQ1BMVVNfUEhZPW0KQ09ORklHX1JFQUxURUtf
UEhZPW0KQ09ORklHX05BVElPTkFMX1BIWT1tCkNPTkZJR19TVEUxMFhQPW0KQ09ORklHX0xTSV9F
VDEwMTFDX1BIWT1tCkNPTkZJR19NSUNSRUxfUEhZPW0KQ09ORklHX01ESU9fQklUQkFORz1tCkNP
TkZJR19QTElQPW0KQ09ORklHX1BQUD1tCkNPTkZJR19QUFBfQlNEQ09NUD1tCkNPTkZJR19QUFBf
REVGTEFURT1tCkNPTkZJR19QUFBfRklMVEVSPXkKQ09ORklHX1BQUF9NUFBFPW0KQ09ORklHX1BQ
UF9NVUxUSUxJTks9eQpDT05GSUdfUFBQT0FUTT1tCkNPTkZJR19QUFBPRT1tCkNPTkZJR19QUFRQ
PW0KQ09ORklHX1BQUE9MMlRQPW0KQ09ORklHX1BQUF9BU1lOQz1tCkNPTkZJR19QUFBfU1lOQ19U
VFk9bQpDT05GSUdfU0xJUD1tCkNPTkZJR19TTEhDPW0KQ09ORklHX1NMSVBfQ09NUFJFU1NFRD15
CkNPTkZJR19TTElQX1NNQVJUPXkKQ09ORklHX1NMSVBfTU9ERV9TTElQNj15CgpDT05GSUdfVVNC
X0NBVEM9bQpDT05GSUdfVVNCX0tBV0VUSD1tCkNPTkZJR19VU0JfUEVHQVNVUz1tCkNPTkZJR19V
U0JfUlRMODE1MD1tCkNPTkZJR19VU0JfVVNCTkVUPW0KQ09ORklHX1VTQl9ORVRfQVg4ODE3WD1t
CkNPTkZJR19VU0JfTkVUX0NEQ0VUSEVSPW0KQ09ORklHX1VTQl9ORVRfQ0RDX0VFTT1tCkNPTkZJ
R19VU0JfTkVUX0NEQ19OQ009bQpDT05GSUdfVVNCX05FVF9ETTk2MDE9bQpDT05GSUdfVVNCX05F
VF9TTVNDNzVYWD1tCkNPTkZJR19VU0JfTkVUX1NNU0M5NVhYPW0KQ09ORklHX1VTQl9ORVRfR0w2
MjBBPW0KQ09ORklHX1VTQl9ORVRfTkVUMTA4MD1tCkNPTkZJR19VU0JfTkVUX1BMVVNCPW0KQ09O
RklHX1VTQl9ORVRfTUNTNzgzMD1tCkNPTkZJR19VU0JfTkVUX1JORElTX0hPU1Q9bQpDT05GSUdf
VVNCX05FVF9DRENfU1VCU0VUPW0KQ09ORklHX1VTQl9BTElfTTU2MzI9eQpDT05GSUdfVVNCX0FO
MjcyMD15CkNPTkZJR19VU0JfQkVMS0lOPXkKQ09ORklHX1VTQl9BUk1MSU5VWD15CkNPTkZJR19V
U0JfRVBTT04yODg4PXkKQ09ORklHX1VTQl9LQzIxOTA9eQpDT05GSUdfVVNCX05FVF9aQVVSVVM9
bQpDT05GSUdfVVNCX05FVF9DWDgyMzEwX0VUSD1tCkNPTkZJR19VU0JfTkVUX0tBTE1JQT1tCkNP
TkZJR19VU0JfSFNPPW0KQ09ORklHX1VTQl9ORVRfSU5UNTFYMT1tCkNPTkZJR19VU0JfQ0RDX1BI
T05FVD1tCkNPTkZJR19VU0JfSVBIRVRIPW0KQ09ORklHX1VTQl9TSUVSUkFfTkVUPW0KQ09ORklH
X1VTQl9WTDYwMD1tCkNPTkZJR19XTEFOPXkKQ09ORklHX1BDTUNJQV9SQVlDUz1tCkNPTkZJR19M
SUJFUlRBU19USElORklSTT1tCkNPTkZJR19MSUJFUlRBU19USElORklSTV9VU0I9bQpDT05GSUdf
QUlSTz1tCkNPTkZJR19BVE1FTD1tCkNPTkZJR19QQ0lfQVRNRUw9bQpDT05GSUdfUENNQ0lBX0FU
TUVMPW0KQ09ORklHX0FUNzZDNTBYX1VTQj1tCkNPTkZJR19BSVJPX0NTPW0KQ09ORklHX1BDTUNJ
QV9XTDM1MDE9bQpDT05GSUdfVVNCX1pEMTIwMT1tCkNPTkZJR19VU0JfTkVUX1JORElTX1dMQU49
bQpDT05GSUdfUlRMODE4MD1tCkNPTkZJR19SVEw4MTg3PW0KQ09ORklHX1JUTDgxODdfTEVEUz15
CkNPTkZJR19BRE04MjExPW0KQ09ORklHX01BQzgwMjExX0hXU0lNPW0KQ09ORklHX01XTDhLPW0K
Q09ORklHX0FUSF9DT01NT049bQpDT05GSUdfQVRINUs9bQpDT05GSUdfQVRINUtfUENJPXkKQ09O
RklHX0FUSDlLX0hXPW0KQ09ORklHX0FUSDlLX0NPTU1PTj1tCkNPTkZJR19BVEg5S19CVENPRVhf
U1VQUE9SVD15CkNPTkZJR19BVEg5Sz1tCkNPTkZJR19BVEg5S19QQ0k9eQpDT05GSUdfQVRIOUtf
UkFURV9DT05UUk9MPXkKQ09ORklHX0FUSDlLX0hUQz1tCkNPTkZJR19DQVJMOTE3MD1tCkNPTkZJ
R19DQVJMOTE3MF9MRURTPXkKQ09ORklHX0NBUkw5MTcwX1dQQz15CkNPTkZJR19CNDM9bQpDT05G
SUdfQjQzX0JDTUE9eQpDT05GSUdfQjQzX1NTQj15CkNPTkZJR19CNDNfUENJX0FVVE9TRUxFQ1Q9
eQpDT05GSUdfQjQzX1BDSUNPUkVfQVVUT1NFTEVDVD15CkNPTkZJR19CNDNfUENNQ0lBPXkKQ09O
RklHX0I0M19TRElPPXkKQ09ORklHX0I0M19CQ01BX1BJTz15CkNPTkZJR19CNDNfUElPPXkKQ09O
RklHX0I0M19QSFlfTj15CkNPTkZJR19CNDNfUEhZX0xQPXkKQ09ORklHX0I0M19QSFlfSFQ9eQpD
T05GSUdfQjQzX0xFRFM9eQpDT05GSUdfQjQzX0hXUk5HPXkKQ09ORklHX0I0M0xFR0FDWT1tCkNP
TkZJR19CNDNMRUdBQ1lfUENJX0FVVE9TRUxFQ1Q9eQpDT05GSUdfQjQzTEVHQUNZX1BDSUNPUkVf
QVVUT1NFTEVDVD15CkNPTkZJR19CNDNMRUdBQ1lfTEVEUz15CkNPTkZJR19CNDNMRUdBQ1lfSFdS
Tkc9eQpDT05GSUdfQjQzTEVHQUNZX0RFQlVHPXkKQ09ORklHX0I0M0xFR0FDWV9ETUE9eQpDT05G
SUdfQjQzTEVHQUNZX1BJTz15CkNPTkZJR19CNDNMRUdBQ1lfRE1BX0FORF9QSU9fTU9ERT15CkNP
TkZJR19CUkNNVVRJTD1tCkNPTkZJR19CUkNNU01BQz1tCkNPTkZJR19IT1NUQVA9bQpDT05GSUdf
SE9TVEFQX0ZJUk1XQVJFPXkKQ09ORklHX0hPU1RBUF9QTFg9bQpDT05GSUdfSE9TVEFQX1BDST1t
CkNPTkZJR19IT1NUQVBfQ1M9bQpDT05GSUdfSVBXMjIwMD1tCkNPTkZJR19JUFcyMjAwX01PTklU
T1I9eQpDT05GSUdfSVBXMjIwMF9SQURJT1RBUD15CkNPTkZJR19JUFcyMjAwX1BST01JU0NVT1VT
PXkKQ09ORklHX0lQVzIyMDBfUU9TPXkKQ09ORklHX0xJQklQVz1tCkNPTkZJR19JV0xXSUZJPW0K
Q09ORklHX0lXTERWTT1tCgpDT05GSUdfSVdMV0lGSV9QMlA9eQpDT05GSUdfSVdMRUdBQ1k9bQpD
T05GSUdfSVdMNDk2NT1tCkNPTkZJR19JV0wzOTQ1PW0KCkNPTkZJR19MSUJFUlRBUz1tCkNPTkZJ
R19MSUJFUlRBU19VU0I9bQpDT05GSUdfTElCRVJUQVNfQ1M9bQpDT05GSUdfTElCRVJUQVNfU0RJ
Tz1tCkNPTkZJR19MSUJFUlRBU19TUEk9bQpDT05GSUdfTElCRVJUQVNfTUVTSD15CkNPTkZJR19I
RVJNRVM9bQpDT05GSUdfSEVSTUVTX0NBQ0hFX0ZXX09OX0lOSVQ9eQpDT05GSUdfUExYX0hFUk1F
Uz1tCkNPTkZJR19UTURfSEVSTUVTPW0KQ09ORklHX05PUlRFTF9IRVJNRVM9bQpDT05GSUdfUENN
Q0lBX0hFUk1FUz1tCkNPTkZJR19QQ01DSUFfU1BFQ1RSVU09bQpDT05GSUdfT1JJTk9DT19VU0I9
bQpDT05GSUdfUDU0X0NPTU1PTj1tCkNPTkZJR19QNTRfVVNCPW0KQ09ORklHX1A1NF9QQ0k9bQpD
T05GSUdfUDU0X1NQST1tCkNPTkZJR19QNTRfTEVEUz15CkNPTkZJR19SVDJYMDA9bQpDT05GSUdf
UlQyNDAwUENJPW0KQ09ORklHX1JUMjUwMFBDST1tCkNPTkZJR19SVDYxUENJPW0KQ09ORklHX1JU
MjgwMFBDST1tCkNPTkZJR19SVDI4MDBQQ0lfUlQzM1hYPXkKQ09ORklHX1JUMjgwMFBDSV9SVDM1
WFg9eQpDT05GSUdfUlQyODAwUENJX1JUNTNYWD15CkNPTkZJR19SVDI4MDBQQ0lfUlQzMjkwPXkK
Q09ORklHX1JUMjUwMFVTQj1tCkNPTkZJR19SVDczVVNCPW0KQ09ORklHX1JUMjgwMFVTQj1tCkNP
TkZJR19SVDI4MDBVU0JfUlQzM1hYPXkKQ09ORklHX1JUMjgwMFVTQl9SVDM1WFg9eQpDT05GSUdf
UlQyODAwVVNCX1JUNTNYWD15CkNPTkZJR19SVDI4MDBfTElCPW0KQ09ORklHX1JUMlgwMF9MSUJf
UENJPW0KQ09ORklHX1JUMlgwMF9MSUJfVVNCPW0KQ09ORklHX1JUMlgwMF9MSUI9bQpDT05GSUdf
UlQyWDAwX0xJQl9GSVJNV0FSRT15CkNPTkZJR19SVDJYMDBfTElCX0NSWVBUTz15CkNPTkZJR19S
VDJYMDBfTElCX0xFRFM9eQpDT05GSUdfUlRMODE5MkNFPW0KQ09ORklHX1JUTDgxOTJTRT1tCkNP
TkZJR19SVEw4MTkyREU9bQpDT05GSUdfUlRMODE5MkNVPW0KQ09ORklHX1JUTFdJRkk9bQpDT05G
SUdfUlRMV0lGSV9ERUJVRz15CkNPTkZJR19SVEw4MTkyQ19DT01NT049bQpDT05GSUdfWkQxMjEx
Ulc9bQpDT05GSUdfTVdJRklFWD1tCkNPTkZJR19NV0lGSUVYX1NESU89bQpDT05GSUdfTVdJRklF
WF9QQ0lFPW0KCkNPTkZJR19XSU1BWF9JMjQwME09bQpDT05GSUdfV0lNQVhfSTI0MDBNX1VTQj1t
CkNPTkZJR19XSU1BWF9JMjQwME1fREVCVUdfTEVWRUw9OApDT05GSUdfV0FOPXkKQ09ORklHX0xB
Tk1FRElBPW0KQ09ORklHX0hETEM9bQpDT05GSUdfSERMQ19SQVc9bQpDT05GSUdfSERMQ19SQVdf
RVRIPW0KQ09ORklHX0hETENfQ0lTQ089bQpDT05GSUdfSERMQ19GUj1tCkNPTkZJR19IRExDX1BQ
UD1tCkNPTkZJR19QQ0kyMDBTWU49bQpDT05GSUdfV0FOWEw9bQpDT05GSUdfRkFSU1lOQz1tCkNP
TkZJR19EU0NDND1tCkNPTkZJR19EU0NDNF9QQ0lTWU5DPXkKQ09ORklHX0RTQ0M0X1BDSV9SU1Q9
eQpDT05GSUdfRExDST1tCkNPTkZJR19ETENJX01BWD04CkNPTkZJR19XQU5fUk9VVEVSX0RSSVZF
UlM9bQpDT05GSUdfQ1lDTEFERVNfU1lOQz1tCkNPTkZJR19TQk5JPW0KQ09ORklHX1ZNWE5FVDM9
bQpDT05GSUdfSFlQRVJWX05FVD1tCkNPTkZJR19JU0ROPXkKQ09ORklHX0lTRE5fQ0FQST1tCkNP
TkZJR19JU0ROX0RSVl9BVk1CMV9WRVJCT1NFX1JFQVNPTj15CkNPTkZJR19DQVBJX1RSQUNFPXkK
Q09ORklHX0lTRE5fQ0FQSV9NSURETEVXQVJFPXkKQ09ORklHX0lTRE5fQ0FQSV9DQVBJMjA9bQoK
Q09ORklHX0NBUElfQVZNPXkKQ09ORklHX0lTRE5fRFJWX0FWTUIxX0IxUENJPW0KQ09ORklHX0lT
RE5fRFJWX0FWTUIxX0IxUENJVjQ9eQpDT05GSUdfSVNETl9EUlZfQVZNQjFfQjFQQ01DSUE9bQpD
T05GSUdfSVNETl9EUlZfQVZNQjFfQVZNX0NTPW0KQ09ORklHX0lTRE5fRFJWX0FWTUIxX1QxUENJ
PW0KQ09ORklHX0lTRE5fRFJWX0FWTUIxX0M0PW0KQ09ORklHX0NBUElfRUlDT049eQpDT05GSUdf
SVNETl9ESVZBUz1tCkNPTkZJR19JU0ROX0RJVkFTX0JSSVBDST15CkNPTkZJR19JU0ROX0RJVkFT
X1BSSVBDST15CkNPTkZJR19JU0ROX0RJVkFTX0RJVkFDQVBJPW0KQ09ORklHX0lTRE5fRElWQVNf
VVNFUklEST1tCkNPTkZJR19JU0ROX0RJVkFTX01BSU5UPW0KQ09ORklHX0lTRE5fRFJWX0dJR0FT
RVQ9bQpDT05GSUdfR0lHQVNFVF9DQVBJPXkKQ09ORklHX0dJR0FTRVRfQkFTRT1tCkNPTkZJR19H
SUdBU0VUX00xMDU9bQpDT05GSUdfR0lHQVNFVF9NMTAxPW0KQ09ORklHX0hZU0ROPW0KQ09ORklH
X0hZU0ROX0NBUEk9eQpDT05GSUdfTUlTRE49bQpDT05GSUdfTUlTRE5fRFNQPW0KQ09ORklHX01J
U0ROX0wxT0lQPW0KCkNPTkZJR19NSVNETl9IRkNQQ0k9bQpDT05GSUdfTUlTRE5fSEZDTVVMVEk9
bQpDT05GSUdfTUlTRE5fSEZDVVNCPW0KQ09ORklHX01JU0ROX0FWTUZSSVRaPW0KQ09ORklHX01J
U0ROX1NQRUVERkFYPW0KQ09ORklHX01JU0ROX0lORklORU9OPW0KQ09ORklHX01JU0ROX1c2Njky
PW0KQ09ORklHX01JU0ROX0lQQUM9bQpDT05GSUdfTUlTRE5fSVNBUj1tCgpDT05GSUdfSU5QVVQ9
eQpDT05GSUdfSU5QVVRfRkZfTUVNTEVTUz1tCkNPTkZJR19JTlBVVF9QT0xMREVWPW0KQ09ORklH
X0lOUFVUX1NQQVJTRUtNQVA9bQoKQ09ORklHX0lOUFVUX01PVVNFREVWPXkKQ09ORklHX0lOUFVU
X01PVVNFREVWX1BTQVVYPXkKQ09ORklHX0lOUFVUX01PVVNFREVWX1NDUkVFTl9YPTEwMjQKQ09O
RklHX0lOUFVUX01PVVNFREVWX1NDUkVFTl9ZPTc2OApDT05GSUdfSU5QVVRfSk9ZREVWPW0KQ09O
RklHX0lOUFVUX0VWREVWPW0KCkNPTkZJR19JTlBVVF9LRVlCT0FSRD15CkNPTkZJR19LRVlCT0FS
RF9BRFA1NTg4PW0KQ09ORklHX0tFWUJPQVJEX0FUS0JEPXkKQ09ORklHX0tFWUJPQVJEX1FUMjE2
MD1tCkNPTkZJR19LRVlCT0FSRF9MS0tCRD1tCkNPTkZJR19LRVlCT0FSRF9MTTgzMjM9bQpDT05G
SUdfS0VZQk9BUkRfTUFYNzM1OT1tCkNPTkZJR19LRVlCT0FSRF9ORVdUT049bQpDT05GSUdfS0VZ
Qk9BUkRfT1BFTkNPUkVTPW0KQ09ORklHX0tFWUJPQVJEX1NUT1dBV0FZPW0KQ09ORklHX0tFWUJP
QVJEX1NVTktCRD1tCkNPTkZJR19LRVlCT0FSRF9YVEtCRD1tCkNPTkZJR19JTlBVVF9NT1VTRT15
CkNPTkZJR19NT1VTRV9QUzI9bQpDT05GSUdfTU9VU0VfUFMyX0FMUFM9eQpDT05GSUdfTU9VU0Vf
UFMyX0xPR0lQUzJQUD15CkNPTkZJR19NT1VTRV9QUzJfU1lOQVBUSUNTPXkKQ09ORklHX01PVVNF
X1BTMl9MSUZFQk9PSz15CkNPTkZJR19NT1VTRV9QUzJfVFJBQ0tQT0lOVD15CkNPTkZJR19NT1VT
RV9QUzJfRUxBTlRFQ0g9eQpDT05GSUdfTU9VU0VfUFMyX1NFTlRFTElDPXkKQ09ORklHX01PVVNF
X1NFUklBTD1tCkNPTkZJR19NT1VTRV9BUFBMRVRPVUNIPW0KQ09ORklHX01PVVNFX0JDTTU5NzQ9
bQpDT05GSUdfTU9VU0VfVlNYWFhBQT1tCkNPTkZJR19NT1VTRV9TWU5BUFRJQ1NfSTJDPW0KQ09O
RklHX01PVVNFX1NZTkFQVElDU19VU0I9bQpDT05GSUdfSU5QVVRfSk9ZU1RJQ0s9eQpDT05GSUdf
Sk9ZU1RJQ0tfQU5BTE9HPW0KQ09ORklHX0pPWVNUSUNLX0EzRD1tCkNPTkZJR19KT1lTVElDS19B
REk9bQpDT05GSUdfSk9ZU1RJQ0tfQ09CUkE9bQpDT05GSUdfSk9ZU1RJQ0tfR0YySz1tCkNPTkZJ
R19KT1lTVElDS19HUklQPW0KQ09ORklHX0pPWVNUSUNLX0dSSVBfTVA9bQpDT05GSUdfSk9ZU1RJ
Q0tfR1VJTExFTU9UPW0KQ09ORklHX0pPWVNUSUNLX0lOVEVSQUNUPW0KQ09ORklHX0pPWVNUSUNL
X1NJREVXSU5ERVI9bQpDT05GSUdfSk9ZU1RJQ0tfVE1EQz1tCkNPTkZJR19KT1lTVElDS19JRk9S
Q0U9bQpDT05GSUdfSk9ZU1RJQ0tfSUZPUkNFX1VTQj15CkNPTkZJR19KT1lTVElDS19JRk9SQ0Vf
MjMyPXkKQ09ORklHX0pPWVNUSUNLX1dBUlJJT1I9bQpDT05GSUdfSk9ZU1RJQ0tfTUFHRUxMQU49
bQpDT05GSUdfSk9ZU1RJQ0tfU1BBQ0VPUkI9bQpDT05GSUdfSk9ZU1RJQ0tfU1BBQ0VCQUxMPW0K
Q09ORklHX0pPWVNUSUNLX1NUSU5HRVI9bQpDT05GSUdfSk9ZU1RJQ0tfVFdJREpPWT1tCkNPTkZJ
R19KT1lTVElDS19aSEVOSFVBPW0KQ09ORklHX0pPWVNUSUNLX0RCOT1tCkNPTkZJR19KT1lTVElD
S19HQU1FQ09OPW0KQ09ORklHX0pPWVNUSUNLX1RVUkJPR1JBRlg9bQpDT05GSUdfSk9ZU1RJQ0tf
Sk9ZRFVNUD1tCkNPTkZJR19KT1lTVElDS19YUEFEPW0KQ09ORklHX0pPWVNUSUNLX1hQQURfRkY9
eQpDT05GSUdfSk9ZU1RJQ0tfWFBBRF9MRURTPXkKQ09ORklHX0pPWVNUSUNLX1dBTEtFUkEwNzAx
PW0KQ09ORklHX0lOUFVUX1RBQkxFVD15CkNPTkZJR19UQUJMRVRfVVNCX0FDRUNBRD1tCkNPTkZJ
R19UQUJMRVRfVVNCX0FJUFRFSz1tCkNPTkZJR19UQUJMRVRfVVNCX0dUQ089bQpDT05GSUdfVEFC
TEVUX1VTQl9IQU5XQU5HPW0KQ09ORklHX1RBQkxFVF9VU0JfS0JUQUI9bQpDT05GSUdfVEFCTEVU
X1VTQl9XQUNPTT1tCkNPTkZJR19JTlBVVF9UT1VDSFNDUkVFTj15CkNPTkZJR19UT1VDSFNDUkVF
Tl9BRFM3ODQ2PW0KQ09ORklHX1RPVUNIU0NSRUVOX0FENzg3Nz1tCkNPTkZJR19UT1VDSFNDUkVF
Tl9BRDc4Nzk9bQpDT05GSUdfVE9VQ0hTQ1JFRU5fQUQ3ODc5X0kyQz1tCkNPTkZJR19UT1VDSFND
UkVFTl9EWU5BUFJPPW0KQ09ORklHX1RPVUNIU0NSRUVOX0hBTVBTSElSRT1tCkNPTkZJR19UT1VD
SFNDUkVFTl9FRVRJPW0KQ09ORklHX1RPVUNIU0NSRUVOX0ZVSklUU1U9bQpDT05GSUdfVE9VQ0hT
Q1JFRU5fR1VOWkU9bQpDT05GSUdfVE9VQ0hTQ1JFRU5fRUxPPW0KQ09ORklHX1RPVUNIU0NSRUVO
X1dBQ09NX1c4MDAxPW0KQ09ORklHX1RPVUNIU0NSRUVOX01DUzUwMDA9bQpDT05GSUdfVE9VQ0hT
Q1JFRU5fTVRPVUNIPW0KQ09ORklHX1RPVUNIU0NSRUVOX0lORVhJTz1tCkNPTkZJR19UT1VDSFND
UkVFTl9NSzcxMj1tCkNPTkZJR19UT1VDSFNDUkVFTl9QRU5NT1VOVD1tCkNPTkZJR19UT1VDSFND
UkVFTl9UT1VDSFJJR0hUPW0KQ09ORklHX1RPVUNIU0NSRUVOX1RPVUNIV0lOPW0KQ09ORklHX1RP
VUNIU0NSRUVOX1dNOTdYWD1tCkNPTkZJR19UT1VDSFNDUkVFTl9XTTk3MDU9eQpDT05GSUdfVE9V
Q0hTQ1JFRU5fV005NzEyPXkKQ09ORklHX1RPVUNIU0NSRUVOX1dNOTcxMz15CkNPTkZJR19UT1VD
SFNDUkVFTl9VU0JfQ09NUE9TSVRFPW0KQ09ORklHX1RPVUNIU0NSRUVOX1VTQl9FR0FMQVg9eQpD
T05GSUdfVE9VQ0hTQ1JFRU5fVVNCX1BBTkpJVD15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfM009
eQpDT05GSUdfVE9VQ0hTQ1JFRU5fVVNCX0lUTT15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfRVRV
UkJPPXkKQ09ORklHX1RPVUNIU0NSRUVOX1VTQl9HVU5aRT15CkNPTkZJR19UT1VDSFNDUkVFTl9V
U0JfRE1DX1RTQzEwPXkKQ09ORklHX1RPVUNIU0NSRUVOX1VTQl9JUlRPVUNIPXkKQ09ORklHX1RP
VUNIU0NSRUVOX1VTQl9JREVBTFRFSz15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfR0VORVJBTF9U
T1VDSD15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfR09UT1A9eQpDT05GSUdfVE9VQ0hTQ1JFRU5f
VVNCX0pBU1RFQz15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfRUxPPXkKQ09ORklHX1RPVUNIU0NS
RUVOX1VTQl9FMkk9eQpDT05GSUdfVE9VQ0hTQ1JFRU5fVVNCX1pZVFJPTklDPXkKQ09ORklHX1RP
VUNIU0NSRUVOX1VTQl9FVFRfVEM0NVVTQj15CkNPTkZJR19UT1VDSFNDUkVFTl9VU0JfTkVYSU89
eQpDT05GSUdfVE9VQ0hTQ1JFRU5fVVNCX0VBU1lUT1VDSD15CkNPTkZJR19UT1VDSFNDUkVFTl9U
T1VDSElUMjEzPW0KQ09ORklHX1RPVUNIU0NSRUVOX1RTQzIwMDc9bQpDT05GSUdfVE9VQ0hTQ1JF
RU5fVFBTNjUwN1g9bQpDT05GSUdfSU5QVVRfTUlTQz15CkNPTkZJR19JTlBVVF9QQ1NQS1I9bQpD
T05GSUdfSU5QVVRfQVBBTkVMPW0KQ09ORklHX0lOUFVUX0FUTEFTX0JUTlM9bQpDT05GSUdfSU5Q
VVRfQVRJX1JFTU9URTI9bQpDT05GSUdfSU5QVVRfS0VZU1BBTl9SRU1PVEU9bQpDT05GSUdfSU5Q
VVRfUE9XRVJNQVRFPW0KQ09ORklHX0lOUFVUX1lFQUxJTks9bQpDT05GSUdfSU5QVVRfQ00xMDk9
bQpDT05GSUdfSU5QVVRfVUlOUFVUPW0KQ09ORklHX0lOUFVUX1BDRjUwNjMzX1BNVT1tCgpDT05G
SUdfU0VSSU89eQpDT05GSUdfU0VSSU9fSTgwNDI9eQpDT05GSUdfU0VSSU9fU0VSUE9SVD1tCkNP
TkZJR19TRVJJT19DVDgyQzcxMD1tCkNPTkZJR19TRVJJT19QQVJLQkQ9bQpDT05GSUdfU0VSSU9f
UENJUFMyPW0KQ09ORklHX1NFUklPX0xJQlBTMj15CkNPTkZJR19TRVJJT19SQVc9bQpDT05GSUdf
U0VSSU9fQUxURVJBX1BTMj1tCkNPTkZJR19HQU1FUE9SVD1tCkNPTkZJR19HQU1FUE9SVF9OUzU1
OD1tCkNPTkZJR19HQU1FUE9SVF9MND1tCkNPTkZJR19HQU1FUE9SVF9FTVUxMEsxPW0KQ09ORklH
X0dBTUVQT1JUX0ZNODAxPW0KCkNPTkZJR19WVD15CkNPTkZJR19DT05TT0xFX1RSQU5TTEFUSU9O
Uz15CkNPTkZJR19WVF9DT05TT0xFPXkKQ09ORklHX1ZUX0NPTlNPTEVfU0xFRVA9eQpDT05GSUdf
SFdfQ09OU09MRT15CkNPTkZJR19WVF9IV19DT05TT0xFX0JJTkRJTkc9eQpDT05GSUdfVU5JWDk4
X1BUWVM9eQpDT05GSUdfREVWUFRTX01VTFRJUExFX0lOU1RBTkNFUz15CkNPTkZJR19TRVJJQUxf
Tk9OU1RBTkRBUkQ9eQpDT05GSUdfUk9DS0VUUE9SVD1tCkNPTkZJR19DWUNMQURFUz1tCkNPTkZJ
R19NT1hBX0lOVEVMTElPPW0KQ09ORklHX01PWEFfU01BUlRJTz1tCkNPTkZJR19TWU5DTElOSz1t
CkNPTkZJR19TWU5DTElOS01QPW0KQ09ORklHX1NZTkNMSU5LX0dUPW0KQ09ORklHX05PWk9NST1t
CkNPTkZJR19JU0k9bQpDT05GSUdfTl9IRExDPW0KQ09ORklHX05fR1NNPW0KQ09ORklHX1NUQUxE
UlY9eQoKQ09ORklHX1NFUklBTF84MjUwPXkKQ09ORklHX1NFUklBTF84MjUwX0NPTlNPTEU9eQpD
T05GSUdfRklYX0VBUkxZQ09OX01FTT15CkNPTkZJR19TRVJJQUxfODI1MF9QQ0k9eQpDT05GSUdf
U0VSSUFMXzgyNTBfUE5QPXkKQ09ORklHX1NFUklBTF84MjUwX0NTPW0KQ09ORklHX1NFUklBTF84
MjUwX05SX1VBUlRTPTMyCkNPTkZJR19TRVJJQUxfODI1MF9SVU5USU1FX1VBUlRTPTQKQ09ORklH
X1NFUklBTF84MjUwX0VYVEVOREVEPXkKQ09ORklHX1NFUklBTF84MjUwX01BTllfUE9SVFM9eQpD
T05GSUdfU0VSSUFMXzgyNTBfU0hBUkVfSVJRPXkKQ09ORklHX1NFUklBTF84MjUwX1JTQT15CgpD
T05GSUdfU0VSSUFMX01BWDMxMDA9bQpDT05GSUdfU0VSSUFMX01GRF9IU1U9bQpDT05GSUdfU0VS
SUFMX0NPUkU9eQpDT05GSUdfU0VSSUFMX0NPUkVfQ09OU09MRT15CkNPTkZJR19TRVJJQUxfSlNN
PW0KQ09ORklHX1NFUklBTF9QQ0hfVUFSVD1tCkNPTkZJR19QUklOVEVSPW0KQ09ORklHX1BQREVW
PW0KQ09ORklHX0hWQ19EUklWRVI9eQpDT05GSUdfVklSVElPX0NPTlNPTEU9bQpDT05GSUdfSVBN
SV9IQU5ETEVSPW0KQ09ORklHX0lQTUlfREVWSUNFX0lOVEVSRkFDRT1tCkNPTkZJR19JUE1JX1NJ
PW0KQ09ORklHX0lQTUlfV0FUQ0hET0c9bQpDT05GSUdfSVBNSV9QT1dFUk9GRj1tCkNPTkZJR19I
V19SQU5ET009bQpDT05GSUdfSFdfUkFORE9NX1RJTUVSSU9NRU09bQpDT05GSUdfSFdfUkFORE9N
X0lOVEVMPW0KQ09ORklHX0hXX1JBTkRPTV9BTUQ9bQpDT05GSUdfSFdfUkFORE9NX1ZJQT1tCkNP
TkZJR19IV19SQU5ET01fVklSVElPPW0KQ09ORklHX05WUkFNPW0KQ09ORklHX1IzOTY0PW0KQ09O
RklHX0FQUExJQ09NPW0KCkNPTkZJR19TWU5DTElOS19DUz1tCkNPTkZJR19DQVJETUFOXzQwMDA9
bQpDT05GSUdfQ0FSRE1BTl80MDQwPW0KQ09ORklHX0lQV0lSRUxFU1M9bQpDT05GSUdfTVdBVkU9
bQpDT05GSUdfUkFXX0RSSVZFUj1tCkNPTkZJR19NQVhfUkFXX0RFVlM9MjU2CkNPTkZJR19IUEVU
PXkKQ09ORklHX0hQRVRfTU1BUD15CkNPTkZJR19IQU5HQ0hFQ0tfVElNRVI9bQpDT05GSUdfVENH
X1RQTT1tCkNPTkZJR19UQ0dfVElTPW0KQ09ORklHX1RDR19OU0M9bQpDT05GSUdfVENHX0FUTUVM
PW0KQ09ORklHX1RDR19JTkZJTkVPTj1tCkNPTkZJR19URUxDTE9DSz1tCkNPTkZJR19ERVZQT1JU
PXkKQ09ORklHX0kyQz1tCkNPTkZJR19JMkNfQk9BUkRJTkZPPXkKQ09ORklHX0kyQ19DT01QQVQ9
eQpDT05GSUdfSTJDX0NIQVJERVY9bQpDT05GSUdfSTJDX0hFTFBFUl9BVVRPPXkKQ09ORklHX0ky
Q19TTUJVUz1tCkNPTkZJR19JMkNfQUxHT0JJVD1tCkNPTkZJR19JMkNfQUxHT1BDQT1tCgoKQ09O
RklHX0kyQ19BTEkxNTM1PW0KQ09ORklHX0kyQ19BTEkxNTYzPW0KQ09ORklHX0kyQ19BTEkxNVgz
PW0KQ09ORklHX0kyQ19BTUQ3NTY9bQpDT05GSUdfSTJDX0FNRDc1Nl9TNDg4Mj1tCkNPTkZJR19J
MkNfQU1EODExMT1tCkNPTkZJR19JMkNfSTgwMT1tCkNPTkZJR19JMkNfSVNDSD1tCkNPTkZJR19J
MkNfUElJWDQ9bQpDT05GSUdfSTJDX05GT1JDRTI9bQpDT05GSUdfSTJDX05GT1JDRTJfUzQ5ODU9
bQpDT05GSUdfSTJDX1NJUzU1OTU9bQpDT05GSUdfSTJDX1NJUzYzMD1tCkNPTkZJR19JMkNfU0lT
OTZYPW0KQ09ORklHX0kyQ19WSUE9bQpDT05GSUdfSTJDX1ZJQVBSTz1tCgpDT05GSUdfSTJDX1ND
TUk9bQoKQ09ORklHX0kyQ19FRzIwVD1tCkNPTkZJR19JMkNfT0NPUkVTPW0KQ09ORklHX0kyQ19Q
Q0FfUExBVEZPUk09bQpDT05GSUdfSTJDX1NJTVRFQz1tCgpDT05GSUdfSTJDX0RJT0xBTl9VMkM9
bQpDT05GSUdfSTJDX1BBUlBPUlQ9bQpDT05GSUdfSTJDX1BBUlBPUlRfTElHSFQ9bQpDT05GSUdf
STJDX1RBT1NfRVZNPW0KQ09ORklHX0kyQ19USU5ZX1VTQj1tCgpDT05GSUdfSTJDX1NUVUI9bQpD
T05GSUdfU1BJPXkKQ09ORklHX1NQSV9NQVNURVI9eQoKQ09ORklHX1NQSV9CSVRCQU5HPW0KQ09O
RklHX1NQSV9CVVRURVJGTFk9bQpDT05GSUdfU1BJX0xNNzBfTExQPW0KQ09ORklHX1NQSV9UT1BD
TElGRl9QQ0g9bQoKQ09ORklHX1NQSV9UTEU2MlgwPW0KCkNPTkZJR19QUFM9bQoKQ09ORklHX1BQ
U19DTElFTlRfTERJU0M9bQpDT05GSUdfUFBTX0NMSUVOVF9QQVJQT1JUPW0KCgpDT05GSUdfUFRQ
XzE1ODhfQ0xPQ0s9bQoKQ09ORklHX0FSQ0hfV0FOVF9PUFRJT05BTF9HUElPTElCPXkKQ09ORklH
X0dQSU9MSUI9eQoKCgpDT05GSUdfR1BJT19QQ0g9bQpDT05GSUdfR1BJT19NTF9JT0g9bQoKCgpD
T05GSUdfVzE9bQpDT05GSUdfVzFfQ09OPXkKCkNPTkZJR19XMV9NQVNURVJfTUFUUk9YPW0KQ09O
RklHX1cxX01BU1RFUl9EUzI0OTA9bQpDT05GSUdfVzFfTUFTVEVSX0RTMjQ4Mj1tCgpDT05GSUdf
VzFfU0xBVkVfVEhFUk09bQpDT05GSUdfVzFfU0xBVkVfU01FTT1tCkNPTkZJR19XMV9TTEFWRV9E
UzI0MzE9bQpDT05GSUdfVzFfU0xBVkVfRFMyNDMzPW0KQ09ORklHX1cxX1NMQVZFX0RTMjc2MD1t
CkNPTkZJR19XMV9TTEFWRV9CUTI3MDAwPW0KQ09ORklHX1BPV0VSX1NVUFBMWT15CkNPTkZJR19Q
REFfUE9XRVI9bQpDT05GSUdfQkFUVEVSWV9EUzI3NjA9bQpDT05GSUdfQkFUVEVSWV9EUzI3ODI9
bQpDT05GSUdfQkFUVEVSWV9CUTI3eDAwPW0KQ09ORklHX0JBVFRFUllfQlEyN1gwMF9JMkM9eQpD
T05GSUdfQkFUVEVSWV9CUTI3WDAwX1BMQVRGT1JNPXkKQ09ORklHX0JBVFRFUllfTUFYMTcwNDA9
bQpDT05GSUdfQ0hBUkdFUl9QQ0Y1MDYzMz1tCkNPTkZJR19IV01PTj15CkNPTkZJR19IV01PTl9W
SUQ9bQoKQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJVPW0KQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJV
Mz1tCkNPTkZJR19TRU5TT1JTX0FENzQxND1tCkNPTkZJR19TRU5TT1JTX0FENzQxOD1tCkNPTkZJ
R19TRU5TT1JTX0FEQ1hYPW0KQ09ORklHX1NFTlNPUlNfQURNMTAyMT1tCkNPTkZJR19TRU5TT1JT
X0FETTEwMjU9bQpDT05GSUdfU0VOU09SU19BRE0xMDI2PW0KQ09ORklHX1NFTlNPUlNfQURNMTAy
OT1tCkNPTkZJR19TRU5TT1JTX0FETTEwMzE9bQpDT05GSUdfU0VOU09SU19BRE05MjQwPW0KQ09O
RklHX1NFTlNPUlNfQURUNzQxMT1tCkNPTkZJR19TRU5TT1JTX0FEVDc0NjI9bQpDT05GSUdfU0VO
U09SU19BRFQ3NDcwPW0KQ09ORklHX1NFTlNPUlNfQURUNzQ3NT1tCkNPTkZJR19TRU5TT1JTX0FT
Qzc2MjE9bQpDT05GSUdfU0VOU09SU19LOFRFTVA9bQpDT05GSUdfU0VOU09SU19LMTBURU1QPW0K
Q09ORklHX1NFTlNPUlNfRkFNMTVIX1BPV0VSPW0KQ09ORklHX1NFTlNPUlNfQVNCMTAwPW0KQ09O
RklHX1NFTlNPUlNfQVRYUDE9bQpDT05GSUdfU0VOU09SU19EUzYyMD1tCkNPTkZJR19TRU5TT1JT
X0RTMTYyMT1tCkNPTkZJR19TRU5TT1JTX0k1S19BTUI9bQpDT05GSUdfU0VOU09SU19GNzE4MDVG
PW0KQ09ORklHX1NFTlNPUlNfRjcxODgyRkc9bQpDT05GSUdfU0VOU09SU19GNzUzNzVTPW0KQ09O
RklHX1NFTlNPUlNfRlNDSE1EPW0KQ09ORklHX1NFTlNPUlNfRzc2MEE9bQpDT05GSUdfU0VOU09S
U19HTDUxOFNNPW0KQ09ORklHX1NFTlNPUlNfR0w1MjBTTT1tCkNPTkZJR19TRU5TT1JTX0NPUkVU
RU1QPW0KQ09ORklHX1NFTlNPUlNfSUJNQUVNPW0KQ09ORklHX1NFTlNPUlNfSUJNUEVYPW0KQ09O
RklHX1NFTlNPUlNfSVQ4Nz1tCkNPTkZJR19TRU5TT1JTX0xJTkVBR0U9bQpDT05GSUdfU0VOU09S
U19MTTYzPW0KQ09ORklHX1NFTlNPUlNfTE03MD1tCkNPTkZJR19TRU5TT1JTX0xNNzM9bQpDT05G
SUdfU0VOU09SU19MTTc1PW0KQ09ORklHX1NFTlNPUlNfTE03Nz1tCkNPTkZJR19TRU5TT1JTX0xN
Nzg9bQpDT05GSUdfU0VOU09SU19MTTgwPW0KQ09ORklHX1NFTlNPUlNfTE04Mz1tCkNPTkZJR19T
RU5TT1JTX0xNODU9bQpDT05GSUdfU0VOU09SU19MTTg3PW0KQ09ORklHX1NFTlNPUlNfTE05MD1t
CkNPTkZJR19TRU5TT1JTX0xNOTI9bQpDT05GSUdfU0VOU09SU19MTTkzPW0KQ09ORklHX1NFTlNP
UlNfTFRDNDE1MT1tCkNPTkZJR19TRU5TT1JTX0xUQzQyMTU9bQpDT05GSUdfU0VOU09SU19MVEM0
MjQ1PW0KQ09ORklHX1NFTlNPUlNfTFRDNDI2MT1tCkNPTkZJR19TRU5TT1JTX0xNOTUyNDE9bQpD
T05GSUdfU0VOU09SU19MTTk1MjQ1PW0KQ09ORklHX1NFTlNPUlNfTUFYMTExMT1tCkNPTkZJR19T
RU5TT1JTX01BWDE2MDY1PW0KQ09ORklHX1NFTlNPUlNfTUFYMTYxOT1tCkNPTkZJR19TRU5TT1JT
X01BWDE2Njg9bQpDT05GSUdfU0VOU09SU19NQVg2NjM5PW0KQ09ORklHX1NFTlNPUlNfTUFYNjY0
Mj1tCkNPTkZJR19TRU5TT1JTX01BWDY2NTA9bQpDT05GSUdfU0VOU09SU19OVENfVEhFUk1JU1RP
Uj1tCkNPTkZJR19TRU5TT1JTX1BDODczNjA9bQpDT05GSUdfU0VOU09SU19QQzg3NDI3PW0KQ09O
RklHX1NFTlNPUlNfUENGODU5MT1tCkNPTkZJR19TRU5TT1JTX1NIVDIxPW0KQ09ORklHX1NFTlNP
UlNfU0lTNTU5NT1tCkNPTkZJR19TRU5TT1JTX1NNTTY2NT1tCkNPTkZJR19TRU5TT1JTX0RNRTE3
Mzc9bQpDT05GSUdfU0VOU09SU19FTUMxNDAzPW0KQ09ORklHX1NFTlNPUlNfRU1DMjEwMz1tCkNP
TkZJR19TRU5TT1JTX0VNQzZXMjAxPW0KQ09ORklHX1NFTlNPUlNfU01TQzQ3TTE9bQpDT05GSUdf
U0VOU09SU19TTVNDNDdNMTkyPW0KQ09ORklHX1NFTlNPUlNfU01TQzQ3QjM5Nz1tCkNPTkZJR19T
RU5TT1JTX1NDSDU2WFhfQ09NTU9OPW0KQ09ORklHX1NFTlNPUlNfU0NINTYyNz1tCkNPTkZJR19T
RU5TT1JTX1NDSDU2MzY9bQpDT05GSUdfU0VOU09SU19BRFMxMDE1PW0KQ09ORklHX1NFTlNPUlNf
QURTNzgyOD1tCkNPTkZJR19TRU5TT1JTX0FEUzc4NzE9bQpDT05GSUdfU0VOU09SU19BTUM2ODIx
PW0KQ09ORklHX1NFTlNPUlNfVEhNQzUwPW0KQ09ORklHX1NFTlNPUlNfVE1QMTAyPW0KQ09ORklH
X1NFTlNPUlNfVE1QNDAxPW0KQ09ORklHX1NFTlNPUlNfVE1QNDIxPW0KQ09ORklHX1NFTlNPUlNf
VklBX0NQVVRFTVA9bQpDT05GSUdfU0VOU09SU19WSUE2ODZBPW0KQ09ORklHX1NFTlNPUlNfVlQx
MjExPW0KQ09ORklHX1NFTlNPUlNfVlQ4MjMxPW0KQ09ORklHX1NFTlNPUlNfVzgzNzgxRD1tCkNP
TkZJR19TRU5TT1JTX1c4Mzc5MUQ9bQpDT05GSUdfU0VOU09SU19XODM3OTJEPW0KQ09ORklHX1NF
TlNPUlNfVzgzNzkzPW0KQ09ORklHX1NFTlNPUlNfVzgzNzk1PW0KQ09ORklHX1NFTlNPUlNfVzgz
TDc4NVRTPW0KQ09ORklHX1NFTlNPUlNfVzgzTDc4Nk5HPW0KQ09ORklHX1NFTlNPUlNfVzgzNjI3
SEY9bQpDT05GSUdfU0VOU09SU19XODM2MjdFSEY9bQpDT05GSUdfU0VOU09SU19BUFBMRVNNQz1t
CgpDT05GSUdfU0VOU09SU19BQ1BJX1BPV0VSPW0KQ09ORklHX1NFTlNPUlNfQVRLMDExMD1tCkNP
TkZJR19USEVSTUFMPW0KQ09ORklHX1RIRVJNQUxfSFdNT049eQpDT05GSUdfV0FUQ0hET0c9eQpD
T05GSUdfV0FUQ0hET0dfQ09SRT15CgpDT05GSUdfU09GVF9XQVRDSERPRz1tCkNPTkZJR19BQ1FV
SVJFX1dEVD1tCkNPTkZJR19BRFZBTlRFQ0hfV0RUPW0KQ09ORklHX0FMSU0xNTM1X1dEVD1tCkNP
TkZJR19BTElNNzEwMV9XRFQ9bQpDT05GSUdfRjcxODA4RV9XRFQ9bQpDT05GSUdfU1A1MTAwX1RD
Tz1tCkNPTkZJR19TQzUyMF9XRFQ9bQpDT05GSUdfU0JDX0ZJVFBDMl9XQVRDSERPRz1tCkNPTkZJ
R19FVVJPVEVDSF9XRFQ9bQpDT05GSUdfSUI3MDBfV0RUPW0KQ09ORklHX0lCTUFTUj1tCkNPTkZJ
R19XQUZFUl9XRFQ9bQpDT05GSUdfSTYzMDBFU0JfV0RUPW0KQ09ORklHX0lUQ09fV0RUPW0KQ09O
RklHX0lUQ09fVkVORE9SX1NVUFBPUlQ9eQpDT05GSUdfSVQ4NzEyRl9XRFQ9bQpDT05GSUdfSVQ4
N19XRFQ9bQpDT05GSUdfSFBfV0FUQ0hET0c9bQpDT05GSUdfSFBXRFRfTk1JX0RFQ09ESU5HPXkK
Q09ORklHX1NDMTIwMF9XRFQ9bQpDT05GSUdfUEM4NzQxM19XRFQ9bQpDT05GSUdfTlZfVENPPW0K
Q09ORklHXzYwWFhfV0RUPW0KQ09ORklHX1NCQzgzNjBfV0RUPW0KQ09ORklHX0NQVTVfV0RUPW0K
Q09ORklHX1NNU0NfU0NIMzExWF9XRFQ9bQpDT05GSUdfU01TQzM3Qjc4N19XRFQ9bQpDT05GSUdf
VzgzNjI3SEZfV0RUPW0KQ09ORklHX1c4MzY5N0hGX1dEVD1tCkNPTkZJR19XODM2OTdVR19XRFQ9
bQpDT05GSUdfVzgzODc3Rl9XRFQ9bQpDT05GSUdfVzgzOTc3Rl9XRFQ9bQpDT05GSUdfTUFDSFpf
V0RUPW0KQ09ORklHX1NCQ19FUFhfQzNfV0FUQ0hET0c9bQoKQ09ORklHX1BDSVBDV0FUQ0hET0c9
bQpDT05GSUdfV0RUUENJPW0KCkNPTkZJR19VU0JQQ1dBVENIRE9HPW0KQ09ORklHX1NTQl9QT1NT
SUJMRT15CgpDT05GSUdfU1NCPW0KQ09ORklHX1NTQl9TUFJPTT15CkNPTkZJR19TU0JfQkxPQ0tJ
Tz15CkNPTkZJR19TU0JfUENJSE9TVF9QT1NTSUJMRT15CkNPTkZJR19TU0JfUENJSE9TVD15CkNP
TkZJR19TU0JfQjQzX1BDSV9CUklER0U9eQpDT05GSUdfU1NCX1BDTUNJQUhPU1RfUE9TU0lCTEU9
eQpDT05GSUdfU1NCX1BDTUNJQUhPU1Q9eQpDT05GSUdfU1NCX1NESU9IT1NUX1BPU1NJQkxFPXkK
Q09ORklHX1NTQl9TRElPSE9TVD15CkNPTkZJR19TU0JfRFJJVkVSX1BDSUNPUkVfUE9TU0lCTEU9
eQpDT05GSUdfU1NCX0RSSVZFUl9QQ0lDT1JFPXkKQ09ORklHX0JDTUFfUE9TU0lCTEU9eQoKQ09O
RklHX0JDTUE9bQpDT05GSUdfQkNNQV9CTE9DS0lPPXkKQ09ORklHX0JDTUFfSE9TVF9QQ0lfUE9T
U0lCTEU9eQpDT05GSUdfQkNNQV9IT1NUX1BDST15CgpDT05GSUdfTUZEX0NPUkU9bQpDT05GSUdf
TUZEX1NNNTAxPW0KQ09ORklHX0hUQ19QQVNJQzM9bQpDT05GSUdfVFBTNjUwMTA9bQpDT05GSUdf
TUZEX1BDRjUwNjMzPW0KQ09ORklHX1BDRjUwNjMzX0FEQz1tCkNPTkZJR19QQ0Y1MDYzM19HUElP
PW0KQ09ORklHX0xQQ19TQ0g9bQpDT05GSUdfTFBDX0lDSD1tCkNPTkZJR19NRkRfV0wxMjczX0NP
UkU9bQpDT05GSUdfUkVHVUxBVE9SPXkKQ09ORklHX1JFR1VMQVRPUl9GSVhFRF9WT0xUQUdFPW0K
Q09ORklHX1JFR1VMQVRPUl9VU0VSU1BBQ0VfQ09OU1VNRVI9bQpDT05GSUdfUkVHVUxBVE9SX01B
WDE1ODY9bQpDT05GSUdfUkVHVUxBVE9SX01BWDg2NDk9bQpDT05GSUdfUkVHVUxBVE9SX01BWDg2
NjA9bQpDT05GSUdfUkVHVUxBVE9SX0xQMzk3MT1tCkNPTkZJR19SRUdVTEFUT1JfUENGNTA2MzM9
bQpDT05GSUdfUkVHVUxBVE9SX1RQUzY1MDIzPW0KQ09ORklHX1JFR1VMQVRPUl9UUFM2NTA3WD1t
CkNPTkZJR19NRURJQV9TVVBQT1JUPW0KCgoKQ09ORklHX0FHUD15CkNPTkZJR19BR1BfQU1ENjQ9
eQpDT05GSUdfQUdQX0lOVEVMPXkKQ09ORklHX0FHUF9TSVM9eQpDT05GSUdfQUdQX1ZJQT15CkNP
TkZJR19WR0FfQVJCPXkKQ09ORklHX1ZHQV9BUkJfTUFYX0dQVVM9MTYKQ09ORklHX1ZHQV9TV0lU
Q0hFUk9PPXkKQ09ORklHX0RSTT1tCkNPTkZJR19EUk1fS01TX0hFTFBFUj1tCkNPTkZJR19EUk1f
VFRNPW0KQ09ORklHX0RSTV9UREZYPW0KQ09ORklHX0RSTV9SMTI4PW0KQ09ORklHX0RSTV9SQURF
T049bQpDT05GSUdfRFJNX1JBREVPTl9LTVM9eQpDT05GSUdfRFJNX05PVVZFQVU9bQpDT05GSUdf
RFJNX05PVVZFQVVfQkFDS0xJR0hUPXkKCkNPTkZJR19EUk1fSTJDX0NINzAwNj1tCkNPTkZJR19E
Uk1fSTJDX1NJTDE2ND1tCkNPTkZJR19EUk1fSTkxNT1tCkNPTkZJR19EUk1fSTkxNV9LTVM9eQpD
T05GSUdfRFJNX01HQT1tCkNPTkZJR19EUk1fU0lTPW0KQ09ORklHX0RSTV9WSUE9bQpDT05GSUdf
RFJNX1NBVkFHRT1tCkNPTkZJR19EUk1fVk1XR0ZYPW0KQ09ORklHX1ZHQVNUQVRFPW0KQ09ORklH
X1ZJREVPX09VVFBVVF9DT05UUk9MPW0KQ09ORklHX0ZCPXkKQ09ORklHX0ZJUk1XQVJFX0VESUQ9
eQpDT05GSUdfRkJfRERDPW0KQ09ORklHX0ZCX0JPT1RfVkVTQV9TVVBQT1JUPXkKQ09ORklHX0ZC
X0NGQl9GSUxMUkVDVD15CkNPTkZJR19GQl9DRkJfQ09QWUFSRUE9eQpDT05GSUdfRkJfQ0ZCX0lN
QUdFQkxJVD15CkNPTkZJR19GQl9TWVNfRklMTFJFQ1Q9bQpDT05GSUdfRkJfU1lTX0NPUFlBUkVB
PW0KQ09ORklHX0ZCX1NZU19JTUFHRUJMSVQ9bQpDT05GSUdfRkJfU1lTX0ZPUFM9bQpDT05GSUdf
RkJfREVGRVJSRURfSU89eQpDT05GSUdfRkJfSEVDVUJBPW0KQ09ORklHX0ZCX1NWR0FMSUI9bQpD
T05GSUdfRkJfQkFDS0xJR0hUPXkKQ09ORklHX0ZCX01PREVfSEVMUEVSUz15CkNPTkZJR19GQl9U
SUxFQkxJVFRJTkc9eQoKQ09ORklHX0ZCX0NJUlJVUz1tCkNPTkZJR19GQl9QTTI9bQpDT05GSUdf
RkJfUE0yX0ZJRk9fRElTQ09OTkVDVD15CkNPTkZJR19GQl9DWUJFUjIwMDA9bQpDT05GSUdfRkJf
Q1lCRVIyMDAwX0REQz15CkNPTkZJR19GQl9BUkM9bQpDT05GSUdfRkJfVkdBMTY9bQpDT05GSUdf
RkJfVVZFU0E9bQpDT05GSUdfRkJfVkVTQT15CkNPTkZJR19GQl9FRkk9eQpDT05GSUdfRkJfTjQx
MT1tCkNPTkZJR19GQl9IR0E9bQpDT05GSUdfRkJfUzFEMTNYWFg9bQpDT05GSUdfRkJfTEU4MDU3
OD1tCkNPTkZJR19GQl9DQVJJTExPX1JBTkNIPW0KQ09ORklHX0ZCX01BVFJPWD1tCkNPTkZJR19G
Ql9NQVRST1hfTUlMTEVOSVVNPXkKQ09ORklHX0ZCX01BVFJPWF9NWVNUSVFVRT15CkNPTkZJR19G
Ql9NQVRST1hfRz15CkNPTkZJR19GQl9NQVRST1hfSTJDPW0KQ09ORklHX0ZCX01BVFJPWF9NQVZF
Tj1tCkNPTkZJR19GQl9SQURFT049bQpDT05GSUdfRkJfUkFERU9OX0kyQz15CkNPTkZJR19GQl9S
QURFT05fQkFDS0xJR0hUPXkKQ09ORklHX0ZCX0FUWTEyOD1tCkNPTkZJR19GQl9BVFkxMjhfQkFD
S0xJR0hUPXkKQ09ORklHX0ZCX0FUWT1tCkNPTkZJR19GQl9BVFlfQ1Q9eQpDT05GSUdfRkJfQVRZ
X0dYPXkKQ09ORklHX0ZCX0FUWV9CQUNLTElHSFQ9eQpDT05GSUdfRkJfUzM9bQpDT05GSUdfRkJf
UzNfRERDPXkKQ09ORklHX0ZCX1NBVkFHRT1tCkNPTkZJR19GQl9TSVM9bQpDT05GSUdfRkJfU0lT
XzMwMD15CkNPTkZJR19GQl9TSVNfMzE1PXkKQ09ORklHX0ZCX1ZJQT1tCkNPTkZJR19GQl9WSUFf
WF9DT01QQVRJQklMSVRZPXkKQ09ORklHX0ZCX05FT01BR0lDPW0KQ09ORklHX0ZCX0tZUk89bQpD
T05GSUdfRkJfM0RGWD1tCkNPTkZJR19GQl8zREZYX0kyQz15CkNPTkZJR19GQl9WT09ET08xPW0K
Q09ORklHX0ZCX1ZUODYyMz1tCkNPTkZJR19GQl9UUklERU5UPW0KQ09ORklHX0ZCX0FSSz1tCkNP
TkZJR19GQl9QTTM9bQpDT05GSUdfRkJfU001MDE9bQpDT05GSUdfRkJfVURMPW0KQ09ORklHX0ZC
X1ZJUlRVQUw9bQpDT05GSUdfRkJfTUVUUk9OT01FPW0KQ09ORklHX0ZCX01CODYyWFg9bQpDT05G
SUdfRkJfTUI4NjJYWF9QQ0lfR0RDPXkKQ09ORklHX0ZCX01CODYyWFhfSTJDPXkKQ09ORklHX0JB
Q0tMSUdIVF9MQ0RfU1VQUE9SVD15CkNPTkZJR19CQUNLTElHSFRfQ0xBU1NfREVWSUNFPXkKQ09O
RklHX0JBQ0tMSUdIVF9QUk9HRUFSPW0KQ09ORklHX0JBQ0tMSUdIVF9BUFBMRT1tCgpDT05GSUdf
VkdBX0NPTlNPTEU9eQpDT05GSUdfRFVNTVlfQ09OU09MRT15CkNPTkZJR19GUkFNRUJVRkZFUl9D
T05TT0xFPXkKQ09ORklHX0ZSQU1FQlVGRkVSX0NPTlNPTEVfREVURUNUX1BSSU1BUlk9eQpDT05G
SUdfRlJBTUVCVUZGRVJfQ09OU09MRV9ST1RBVElPTj15CkNPTkZJR19GT05UXzh4OD15CkNPTkZJ
R19GT05UXzh4MTY9eQpDT05GSUdfU09VTkQ9bQpDT05GSUdfU09VTkRfT1NTX0NPUkU9eQpDT05G
SUdfU05EPW0KQ09ORklHX1NORF9USU1FUj1tCkNPTkZJR19TTkRfUENNPW0KQ09ORklHX1NORF9I
V0RFUD1tCkNPTkZJR19TTkRfUkFXTUlEST1tCkNPTkZJR19TTkRfSkFDSz15CkNPTkZJR19TTkRf
U0VRVUVOQ0VSPW0KQ09ORklHX1NORF9TRVFfRFVNTVk9bQpDT05GSUdfU05EX09TU0VNVUw9eQpD
T05GSUdfU05EX01JWEVSX09TUz1tCkNPTkZJR19TTkRfUENNX09TUz1tCkNPTkZJR19TTkRfUENN
X09TU19QTFVHSU5TPXkKQ09ORklHX1NORF9IUlRJTUVSPW0KQ09ORklHX1NORF9TRVFfSFJUSU1F
Ul9ERUZBVUxUPXkKQ09ORklHX1NORF9EWU5BTUlDX01JTk9SUz15CkNPTkZJR19TTkRfU1VQUE9S
VF9PTERfQVBJPXkKQ09ORklHX1NORF9WRVJCT1NFX1BST0NGUz15CkNPTkZJR19TTkRfVk1BU1RF
Uj15CkNPTkZJR19TTkRfS0NUTF9KQUNLPXkKQ09ORklHX1NORF9ETUFfU0dCVUY9eQpDT05GSUdf
U05EX1JBV01JRElfU0VRPW0KQ09ORklHX1NORF9PUEwzX0xJQl9TRVE9bQpDT05GSUdfU05EX0VN
VTEwSzFfU0VRPW0KQ09ORklHX1NORF9NUFU0MDFfVUFSVD1tCkNPTkZJR19TTkRfT1BMM19MSUI9
bQpDT05GSUdfU05EX1ZYX0xJQj1tCkNPTkZJR19TTkRfQUM5N19DT0RFQz1tCkNPTkZJR19TTkRf
RFJJVkVSUz15CkNPTkZJR19TTkRfUENTUD1tCkNPTkZJR19TTkRfRFVNTVk9bQpDT05GSUdfU05E
X0FMT09QPW0KQ09ORklHX1NORF9WSVJNSURJPW0KQ09ORklHX1NORF9NVFBBVj1tCkNPTkZJR19T
TkRfTVRTNjQ9bQpDT05GSUdfU05EX1NFUklBTF9VMTY1NTA9bQpDT05GSUdfU05EX01QVTQwMT1t
CkNPTkZJR19TTkRfUE9SVE1BTjJYND1tCkNPTkZJR19TTkRfQUM5N19QT1dFUl9TQVZFPXkKQ09O
RklHX1NORF9BQzk3X1BPV0VSX1NBVkVfREVGQVVMVD0wCkNPTkZJR19TTkRfU0JfQ09NTU9OPW0K
Q09ORklHX1NORF9TQjE2X0RTUD1tCkNPTkZJR19TTkRfUENJPXkKQ09ORklHX1NORF9BRDE4ODk9
bQpDT05GSUdfU05EX0FMUzMwMD1tCkNPTkZJR19TTkRfQUxTNDAwMD1tCkNPTkZJR19TTkRfQUxJ
NTQ1MT1tCkNPTkZJR19TTkRfQVNJSFBJPW0KQ09ORklHX1NORF9BVElJWFA9bQpDT05GSUdfU05E
X0FUSUlYUF9NT0RFTT1tCkNPTkZJR19TTkRfQVU4ODEwPW0KQ09ORklHX1NORF9BVTg4MjA9bQpD
T05GSUdfU05EX0FVODgzMD1tCkNPTkZJR19TTkRfQVpUMzMyOD1tCkNPTkZJR19TTkRfQlQ4N1g9
bQpDT05GSUdfU05EX0NBMDEwNj1tCkNPTkZJR19TTkRfQ01JUENJPW0KQ09ORklHX1NORF9PWFlH
RU5fTElCPW0KQ09ORklHX1NORF9PWFlHRU49bQpDT05GSUdfU05EX0NTNDI4MT1tCkNPTkZJR19T
TkRfQ1M0NlhYPW0KQ09ORklHX1NORF9DUzQ2WFhfTkVXX0RTUD15CkNPTkZJR19TTkRfQ1M1NTMw
PW0KQ09ORklHX1NORF9DUzU1MzVBVURJTz1tCkNPTkZJR19TTkRfQ1RYRkk9bQpDT05GSUdfU05E
X0RBUkxBMjA9bQpDT05GSUdfU05EX0dJTkEyMD1tCkNPTkZJR19TTkRfTEFZTEEyMD1tCkNPTkZJ
R19TTkRfREFSTEEyND1tCkNPTkZJR19TTkRfR0lOQTI0PW0KQ09ORklHX1NORF9MQVlMQTI0PW0K
Q09ORklHX1NORF9NT05BPW0KQ09ORklHX1NORF9NSUE9bQpDT05GSUdfU05EX0VDSE8zRz1tCkNP
TkZJR19TTkRfSU5ESUdPPW0KQ09ORklHX1NORF9JTkRJR09JTz1tCkNPTkZJR19TTkRfSU5ESUdP
REo9bQpDT05GSUdfU05EX0lORElHT0lPWD1tCkNPTkZJR19TTkRfSU5ESUdPREpYPW0KQ09ORklH
X1NORF9FTVUxMEsxPW0KQ09ORklHX1NORF9FTVUxMEsxWD1tCkNPTkZJR19TTkRfRU5TMTM3MD1t
CkNPTkZJR19TTkRfRU5TMTM3MT1tCkNPTkZJR19TTkRfRVMxOTM4PW0KQ09ORklHX1NORF9FUzE5
Njg9bQpDT05GSUdfU05EX0VTMTk2OF9JTlBVVD15CkNPTkZJR19TTkRfRk04MDE9bQpDT05GSUdf
U05EX0hEQV9JTlRFTD1tCkNPTkZJR19TTkRfSERBX1BSRUFMTE9DX1NJWkU9NjQKQ09ORklHX1NO
RF9IREFfSFdERVA9eQpDT05GSUdfU05EX0hEQV9SRUNPTkZJRz15CkNPTkZJR19TTkRfSERBX0lO
UFVUX0JFRVA9eQpDT05GSUdfU05EX0hEQV9JTlBVVF9CRUVQX01PREU9MQpDT05GSUdfU05EX0hE
QV9JTlBVVF9KQUNLPXkKQ09ORklHX1NORF9IREFfUEFUQ0hfTE9BREVSPXkKQ09ORklHX1NORF9I
REFfQ09ERUNfUkVBTFRFSz15CkNPTkZJR19TTkRfSERBX0NPREVDX0FOQUxPRz15CkNPTkZJR19T
TkRfSERBX0NPREVDX1NJR01BVEVMPXkKQ09ORklHX1NORF9IREFfQ09ERUNfVklBPXkKQ09ORklH
X1NORF9IREFfQ09ERUNfSERNST15CkNPTkZJR19TTkRfSERBX0NPREVDX0NJUlJVUz15CkNPTkZJ
R19TTkRfSERBX0NPREVDX0NPTkVYQU5UPXkKQ09ORklHX1NORF9IREFfQ09ERUNfQ0EwMTEwPXkK
Q09ORklHX1NORF9IREFfQ09ERUNfQ0EwMTMyPXkKQ09ORklHX1NORF9IREFfQ09ERUNfQ01FRElB
PXkKQ09ORklHX1NORF9IREFfQ09ERUNfU0kzMDU0PXkKQ09ORklHX1NORF9IREFfR0VORVJJQz15
CkNPTkZJR19TTkRfSERBX1BPV0VSX1NBVkU9eQpDT05GSUdfU05EX0hEQV9QT1dFUl9TQVZFX0RF
RkFVTFQ9MApDT05GSUdfU05EX0hEU1A9bQpDT05GSUdfU05EX0hEU1BNPW0KQ09ORklHX1NORF9J
Q0UxNzEyPW0KQ09ORklHX1NORF9JQ0UxNzI0PW0KQ09ORklHX1NORF9JTlRFTDhYMD1tCkNPTkZJ
R19TTkRfSU5URUw4WDBNPW0KQ09ORklHX1NORF9LT1JHMTIxMj1tCkNPTkZJR19TTkRfTE9MQT1t
CkNPTkZJR19TTkRfTFg2NDY0RVM9bQpDT05GSUdfU05EX01BRVNUUk8zPW0KQ09ORklHX1NORF9N
QUVTVFJPM19JTlBVVD15CkNPTkZJR19TTkRfTUlYQVJUPW0KQ09ORklHX1NORF9OTTI1Nj1tCkNP
TkZJR19TTkRfUENYSFI9bQpDT05GSUdfU05EX1JJUFRJREU9bQpDT05GSUdfU05EX1JNRTMyPW0K
Q09ORklHX1NORF9STUU5Nj1tCkNPTkZJR19TTkRfUk1FOTY1Mj1tCkNPTkZJR19TTkRfU09OSUNW
SUJFUz1tCkNPTkZJR19TTkRfVFJJREVOVD1tCkNPTkZJR19TTkRfVklBODJYWD1tCkNPTkZJR19T
TkRfVklBODJYWF9NT0RFTT1tCkNPTkZJR19TTkRfVklSVFVPU089bQpDT05GSUdfU05EX1ZYMjIy
PW0KQ09ORklHX1NORF9ZTUZQQ0k9bQpDT05GSUdfU05EX1NQST15CkNPTkZJR19TTkRfVVNCPXkK
Q09ORklHX1NORF9VU0JfQVVESU89bQpDT05GSUdfU05EX1VTQl9VQTEwMT1tCkNPTkZJR19TTkRf
VVNCX1VTWDJZPW0KQ09ORklHX1NORF9VU0JfQ0FJQVE9bQpDT05GSUdfU05EX1VTQl9DQUlBUV9J
TlBVVD15CkNPTkZJR19TTkRfVVNCX1VTMTIyTD1tCkNPTkZJR19TTkRfVVNCXzZGSVJFPW0KQ09O
RklHX1NORF9GSVJFV0lSRT15CkNPTkZJR19TTkRfRklSRVdJUkVfTElCPW0KQ09ORklHX1NORF9G
SVJFV0lSRV9TUEVBS0VSUz1tCkNPTkZJR19TTkRfSVNJR0hUPW0KQ09ORklHX1NORF9QQ01DSUE9
eQpDT05GSUdfU05EX1ZYUE9DS0VUPW0KQ09ORklHX1NORF9QREFVRElPQ0Y9bQpDT05GSUdfQUM5
N19CVVM9bQoKQ09ORklHX0hJRD1tCkNPTkZJR19ISURSQVc9eQpDT05GSUdfSElEX0dFTkVSSUM9
bQoKQ09ORklHX0hJRF9BNFRFQ0g9bQpDT05GSUdfSElEX0FDUlVYPW0KQ09ORklHX0hJRF9BQ1JV
WF9GRj15CkNPTkZJR19ISURfQVBQTEU9bQpDT05GSUdfSElEX0JFTEtJTj1tCkNPTkZJR19ISURf
Q0hFUlJZPW0KQ09ORklHX0hJRF9DSElDT05ZPW0KQ09ORklHX0hJRF9QUk9ESUtFWVM9bQpDT05G
SUdfSElEX0NZUFJFU1M9bQpDT05GSUdfSElEX0RSQUdPTlJJU0U9bQpDT05GSUdfRFJBR09OUklT
RV9GRj15CkNPTkZJR19ISURfRU1TX0ZGPW0KQ09ORklHX0hJRF9FTEVDT009bQpDT05GSUdfSElE
X0VaS0VZPW0KQ09ORklHX0hJRF9IT0xURUs9bQpDT05GSUdfSElEX0tFWVRPVUNIPW0KQ09ORklH
X0hJRF9LWUU9bQpDT05GSUdfSElEX1VDTE9HSUM9bQpDT05GSUdfSElEX1dBTFRPUD1tCkNPTkZJ
R19ISURfR1lSQVRJT049bQpDT05GSUdfSElEX1RXSU5IQU49bQpDT05GSUdfSElEX0tFTlNJTkdU
T049bQpDT05GSUdfSElEX0xDUE9XRVI9bQpDT05GSUdfSElEX0xPR0lURUNIPW0KQ09ORklHX0hJ
RF9MT0dJVEVDSF9ESj1tCkNPTkZJR19MT0dJVEVDSF9GRj15CkNPTkZJR19MT0dJUlVNQkxFUEFE
Ml9GRj15CkNPTkZJR19MT0dJRzk0MF9GRj15CkNPTkZJR19MT0dJV0hFRUxTX0ZGPXkKQ09ORklH
X0hJRF9NQUdJQ01PVVNFPW0KQ09ORklHX0hJRF9NSUNST1NPRlQ9bQpDT05GSUdfSElEX01PTlRF
UkVZPW0KQ09ORklHX0hJRF9NVUxUSVRPVUNIPW0KQ09ORklHX0hJRF9OVFJJRz1tCkNPTkZJR19I
SURfT1JURUs9bQpDT05GSUdfSElEX1BBTlRIRVJMT1JEPW0KQ09ORklHX1BBTlRIRVJMT1JEX0ZG
PXkKQ09ORklHX0hJRF9QRVRBTFlOWD1tCkNPTkZJR19ISURfUElDT0xDRD1tCkNPTkZJR19ISURf
UElDT0xDRF9GQj15CkNPTkZJR19ISURfUElDT0xDRF9CQUNLTElHSFQ9eQpDT05GSUdfSElEX1BJ
Q09MQ0RfTEVEUz15CkNPTkZJR19ISURfUFJJTUFYPW0KQ09ORklHX0hJRF9ST0NDQVQ9bQpDT05G
SUdfSElEX1NBTVNVTkc9bQpDT05GSUdfSElEX1NPTlk9bQpDT05GSUdfSElEX1NQRUVETElOSz1t
CkNPTkZJR19ISURfU1VOUExVUz1tCkNPTkZJR19ISURfR1JFRU5BU0lBPW0KQ09ORklHX0dSRUVO
QVNJQV9GRj15CkNPTkZJR19ISURfU01BUlRKT1lQTFVTPW0KQ09ORklHX1NNQVJUSk9ZUExVU19G
Rj15CkNPTkZJR19ISURfVE9QU0VFRD1tCkNPTkZJR19ISURfVEhSVVNUTUFTVEVSPW0KQ09ORklH
X1RIUlVTVE1BU1RFUl9GRj15CkNPTkZJR19ISURfV0FDT009bQpDT05GSUdfSElEX1dJSU1PVEU9
bQpDT05GSUdfSElEX1dJSU1PVEVfRVhUPXkKQ09ORklHX0hJRF9aRVJPUExVUz1tCkNPTkZJR19a
RVJPUExVU19GRj15CkNPTkZJR19ISURfWllEQUNST049bQoKQ09ORklHX1VTQl9ISUQ9bQpDT05G
SUdfSElEX1BJRD15CkNPTkZJR19VU0JfSElEREVWPXkKQ09ORklHX1VTQl9BUkNIX0hBU19PSENJ
PXkKQ09ORklHX1VTQl9BUkNIX0hBU19FSENJPXkKQ09ORklHX1VTQl9BUkNIX0hBU19YSENJPXkK
Q09ORklHX1VTQl9TVVBQT1JUPXkKQ09ORklHX1VTQl9DT01NT049bQpDT05GSUdfVVNCX0FSQ0hf
SEFTX0hDRD15CkNPTkZJR19VU0I9bQpDT05GSUdfVVNCX0FOTk9VTkNFX05FV19ERVZJQ0VTPXkK
CkNPTkZJR19VU0JfRFlOQU1JQ19NSU5PUlM9eQpDT05GSUdfVVNCX1NVU1BFTkQ9eQpDT05GSUdf
VVNCX01PTj1tCkNPTkZJR19VU0JfV1VTQj1tCkNPTkZJR19VU0JfV1VTQl9DQkFGPW0KCkNPTkZJ
R19VU0JfQzY3WDAwX0hDRD1tCkNPTkZJR19VU0JfWEhDSV9IQ0Q9bQpDT05GSUdfVVNCX0VIQ0lf
SENEPW0KQ09ORklHX1VTQl9FSENJX1JPT1RfSFVCX1RUPXkKQ09ORklHX1VTQl9FSENJX1RUX05F
V1NDSEVEPXkKQ09ORklHX1VTQl9JU1AxMTZYX0hDRD1tCkNPTkZJR19VU0JfT0hDSV9IQ0Q9bQpD
T05GSUdfVVNCX09IQ0lfTElUVExFX0VORElBTj15CkNPTkZJR19VU0JfVUhDSV9IQ0Q9bQpDT05G
SUdfVVNCX1UxMzJfSENEPW0KQ09ORklHX1VTQl9TTDgxMV9IQ0Q9bQpDT05GSUdfVVNCX1NMODEx
X0NTPW0KQ09ORklHX1VTQl9SOEE2NjU5N19IQ0Q9bQpDT05GSUdfVVNCX1dIQ0lfSENEPW0KQ09O
RklHX1VTQl9IV0FfSENEPW0KCkNPTkZJR19VU0JfQUNNPW0KQ09ORklHX1VTQl9QUklOVEVSPW0K
Q09ORklHX1VTQl9XRE09bQpDT05GSUdfVVNCX1RNQz1tCgoKQ09ORklHX1VTQl9TVE9SQUdFPW0K
Q09ORklHX1VTQl9TVE9SQUdFX1JFQUxURUs9bQpDT05GSUdfUkVBTFRFS19BVVRPUE09eQpDT05G
SUdfVVNCX1NUT1JBR0VfREFUQUZBQj1tCkNPTkZJR19VU0JfU1RPUkFHRV9GUkVFQ09NPW0KQ09O
RklHX1VTQl9TVE9SQUdFX0lTRDIwMD1tCkNPTkZJR19VU0JfU1RPUkFHRV9VU0JBVD1tCkNPTkZJ
R19VU0JfU1RPUkFHRV9TRERSMDk9bQpDT05GSUdfVVNCX1NUT1JBR0VfU0REUjU1PW0KQ09ORklH
X1VTQl9TVE9SQUdFX0pVTVBTSE9UPW0KQ09ORklHX1VTQl9TVE9SQUdFX0FMQVVEQT1tCkNPTkZJ
R19VU0JfU1RPUkFHRV9PTkVUT1VDSD1tCkNPTkZJR19VU0JfU1RPUkFHRV9LQVJNQT1tCkNPTkZJ
R19VU0JfU1RPUkFHRV9DWVBSRVNTX0FUQUNCPW0KQ09ORklHX1VTQl9TVE9SQUdFX0VORV9VQjYy
NTA9bQpDT05GSUdfVVNCX1VBUz1tCgpDT05GSUdfVVNCX01EQzgwMD1tCkNPTkZJR19VU0JfTUlD
Uk9URUs9bQoKQ09ORklHX1VTQl9VU1M3MjA9bQpDT05GSUdfVVNCX1NFUklBTD1tCkNPTkZJR19V
U0JfRVpVU0I9eQpDT05GSUdfVVNCX1NFUklBTF9HRU5FUklDPXkKQ09ORklHX1VTQl9TRVJJQUxf
QUlSQ0FCTEU9bQpDT05GSUdfVVNCX1NFUklBTF9BUkszMTE2PW0KQ09ORklHX1VTQl9TRVJJQUxf
QkVMS0lOPW0KQ09ORklHX1VTQl9TRVJJQUxfQ0gzNDE9bQpDT05GSUdfVVNCX1NFUklBTF9XSElU
RUhFQVQ9bQpDT05GSUdfVVNCX1NFUklBTF9ESUdJX0FDQ0VMRVBPUlQ9bQpDT05GSUdfVVNCX1NF
UklBTF9DUDIxMFg9bQpDT05GSUdfVVNCX1NFUklBTF9DWVBSRVNTX004PW0KQ09ORklHX1VTQl9T
RVJJQUxfRU1QRUc9bQpDT05GSUdfVVNCX1NFUklBTF9GVERJX1NJTz1tCkNPTkZJR19VU0JfU0VS
SUFMX0ZVTlNPRlQ9bQpDT05GSUdfVVNCX1NFUklBTF9WSVNPUj1tCkNPTkZJR19VU0JfU0VSSUFM
X0lQQVE9bQpDT05GSUdfVVNCX1NFUklBTF9JUj1tCkNPTkZJR19VU0JfU0VSSUFMX0VER0VQT1JU
PW0KQ09ORklHX1VTQl9TRVJJQUxfRURHRVBPUlRfVEk9bQpDT05GSUdfVVNCX1NFUklBTF9HQVJN
SU49bQpDT05GSUdfVVNCX1NFUklBTF9JUFc9bQpDT05GSUdfVVNCX1NFUklBTF9JVVU9bQpDT05G
SUdfVVNCX1NFUklBTF9LRVlTUEFOX1BEQT1tCkNPTkZJR19VU0JfU0VSSUFMX0tFWVNQQU49bQpD
T05GSUdfVVNCX1NFUklBTF9LTFNJPW0KQ09ORklHX1VTQl9TRVJJQUxfS09CSUxfU0NUPW0KQ09O
RklHX1VTQl9TRVJJQUxfTUNUX1UyMzI9bQpDT05GSUdfVVNCX1NFUklBTF9NT1M3NzIwPW0KQ09O
RklHX1VTQl9TRVJJQUxfTU9TNzcxNV9QQVJQT1JUPXkKQ09ORklHX1VTQl9TRVJJQUxfTU9TNzg0
MD1tCkNPTkZJR19VU0JfU0VSSUFMX01PVE9ST0xBPW0KQ09ORklHX1VTQl9TRVJJQUxfTkFWTUFO
PW0KQ09ORklHX1VTQl9TRVJJQUxfUEwyMzAzPW0KQ09ORklHX1VTQl9TRVJJQUxfT1RJNjg1OD1t
CkNPTkZJR19VU0JfU0VSSUFMX1FDQVVYPW0KQ09ORklHX1VTQl9TRVJJQUxfUVVBTENPTU09bQpD
T05GSUdfVVNCX1NFUklBTF9TUENQOFg1PW0KQ09ORklHX1VTQl9TRVJJQUxfSFA0WD1tCkNPTkZJ
R19VU0JfU0VSSUFMX1NBRkU9bQpDT05GSUdfVVNCX1NFUklBTF9TSUVNRU5TX01QST1tCkNPTkZJ
R19VU0JfU0VSSUFMX1NJRVJSQVdJUkVMRVNTPW0KQ09ORklHX1VTQl9TRVJJQUxfU1lNQk9MPW0K
Q09ORklHX1VTQl9TRVJJQUxfVEk9bQpDT05GSUdfVVNCX1NFUklBTF9DWUJFUkpBQ0s9bQpDT05G
SUdfVVNCX1NFUklBTF9YSVJDT009bQpDT05GSUdfVVNCX1NFUklBTF9XV0FOPW0KQ09ORklHX1VT
Ql9TRVJJQUxfT1BUSU9OPW0KQ09ORklHX1VTQl9TRVJJQUxfT01OSU5FVD1tCkNPTkZJR19VU0Jf
U0VSSUFMX09QVElDT049bQpDT05GSUdfVVNCX1NFUklBTF9WSVZPUEFZX1NFUklBTD1tCkNPTkZJ
R19VU0JfU0VSSUFMX1pJTz1tCkNPTkZJR19VU0JfU0VSSUFMX1NTVTEwMD1tCkNPTkZJR19VU0Jf
U0VSSUFMX0RFQlVHPW0KCkNPTkZJR19VU0JfRU1JNjI9bQpDT05GSUdfVVNCX0VNSTI2PW0KQ09O
RklHX1VTQl9BRFVUVVg9bQpDT05GSUdfVVNCX1NFVlNFRz1tCkNPTkZJR19VU0JfUklPNTAwPW0K
Q09ORklHX1VTQl9MRUdPVE9XRVI9bQpDT05GSUdfVVNCX0xDRD1tCkNPTkZJR19VU0JfTEVEPW0K
Q09ORklHX1VTQl9DWVBSRVNTX0NZN0M2Mz1tCkNPTkZJR19VU0JfQ1lUSEVSTT1tCkNPTkZJR19V
U0JfSURNT1VTRT1tCkNPTkZJR19VU0JfRlRESV9FTEFOPW0KQ09ORklHX1VTQl9BUFBMRURJU1BM
QVk9bQpDT05GSUdfVVNCX1NJU1VTQlZHQT1tCkNPTkZJR19VU0JfU0lTVVNCVkdBX0NPTj15CkNP
TkZJR19VU0JfTEQ9bQpDT05GSUdfVVNCX1RSQU5DRVZJQlJBVE9SPW0KQ09ORklHX1VTQl9JT1dB
UlJJT1I9bQpDT05GSUdfVVNCX1RFU1Q9bQpDT05GSUdfVVNCX0lTSUdIVEZXPW0KQ09ORklHX1VT
Ql9ZVVJFWD1tCgpDT05GSUdfVVNCX0FUTT1tCkNPTkZJR19VU0JfU1BFRURUT1VDSD1tCkNPTkZJ
R19VU0JfQ1hBQ1JVPW0KQ09ORklHX1VTQl9VRUFHTEVBVE09bQpDT05GSUdfVVNCX1hVU0JBVE09
bQpDT05GSUdfVVNCX0dBREdFVD1tCkNPTkZJR19VU0JfR0FER0VUX1ZCVVNfRFJBVz0yCkNPTkZJ
R19VU0JfR0FER0VUX1NUT1JBR0VfTlVNX0JVRkZFUlM9MgoKQ09ORklHX1VTQl9FRzIwVD1tCkNP
TkZJR19VU0JfR0FER0VUX0RVQUxTUEVFRD15CgpDT05GSUdfVVNCX09UR19VVElMUz15CkNPTkZJ
R19OT1BfVVNCX1hDRUlWPW0KQ09ORklHX1VXQj1tCkNPTkZJR19VV0JfSFdBPW0KQ09ORklHX1VX
Ql9XSENJPW0KQ09ORklHX1VXQl9JMTQ4MFU9bQpDT05GSUdfTU1DPW0KCkNPTkZJR19NTUNfQkxP
Q0s9bQpDT05GSUdfTU1DX0JMT0NLX01JTk9SUz04CkNPTkZJR19NTUNfQkxPQ0tfQk9VTkNFPXkK
Q09ORklHX1NESU9fVUFSVD1tCgpDT05GSUdfTU1DX1NESENJPW0KQ09ORklHX01NQ19TREhDSV9Q
Q0k9bQpDT05GSUdfTU1DX1JJQ09IX01NQz15CkNPTkZJR19NTUNfU0RIQ0lfUExURk09bQpDT05G
SUdfTU1DX1dCU0Q9bQpDT05GSUdfTU1DX1RJRk1fU0Q9bQpDT05GSUdfTU1DX1NQST1tCkNPTkZJ
R19NTUNfU0RSSUNPSF9DUz1tCkNPTkZJR19NTUNfQ0I3MTA9bQpDT05GSUdfTU1DX1ZJQV9TRE1N
Qz1tCkNPTkZJR19NTUNfVlVCMzAwPW0KQ09ORklHX01NQ19VU0hDPW0KQ09ORklHX01FTVNUSUNL
PW0KCkNPTkZJR19NU1BST19CTE9DSz1tCgpDT05GSUdfTUVNU1RJQ0tfVElGTV9NUz1tCkNPTkZJ
R19NRU1TVElDS19KTUlDUk9OXzM4WD1tCkNPTkZJR19NRU1TVElDS19SNTkyPW0KQ09ORklHX05F
V19MRURTPXkKQ09ORklHX0xFRFNfQ0xBU1M9eQoKQ09ORklHX0xFRFNfUENBOTUzMj1tCkNPTkZJ
R19MRURTX0xQMzk0ND1tCkNPTkZJR19MRURTX0NMRVZPX01BSUw9bQpDT05GSUdfTEVEU19QQ0E5
NTVYPW0KQ09ORklHX0xFRFNfREFDMTI0UzA4NT1tCkNPTkZJR19MRURTX1JFR1VMQVRPUj1tCkNP
TkZJR19MRURTX0JEMjgwMj1tCkNPTkZJR19MRURTX0lOVEVMX1NTNDIwMD1tCkNPTkZJR19MRURT
X0xUMzU5Mz1tCkNPTkZJR19MRURTX0RFTExfTkVUQk9PS1M9bQpDT05GSUdfTEVEU19UUklHR0VS
Uz15CgpDT05GSUdfTEVEU19UUklHR0VSX1RJTUVSPW0KQ09ORklHX0xFRFNfVFJJR0dFUl9IRUFS
VEJFQVQ9bQpDT05GSUdfTEVEU19UUklHR0VSX0JBQ0tMSUdIVD1tCkNPTkZJR19MRURTX1RSSUdH
RVJfREVGQVVMVF9PTj1tCgpDT05GSUdfQUNDRVNTSUJJTElUWT15CkNPTkZJR19BMTFZX0JSQUlM
TEVfQ09OU09MRT15CkNPTkZJR19FREFDPXkKCkNPTkZJR19FREFDX0xFR0FDWV9TWVNGUz15CkNP
TkZJR19FREFDX0RFQ09ERV9NQ0U9bQpDT05GSUdfRURBQ19NTV9FREFDPW0KQ09ORklHX0VEQUNf
QU1ENjQ9bQpDT05GSUdfRURBQ19FNzUyWD1tCkNPTkZJR19FREFDX0k4Mjk3NVg9bQpDT05GSUdf
RURBQ19JMzAwMD1tCkNPTkZJR19FREFDX0kzMjAwPW0KQ09ORklHX0VEQUNfWDM4PW0KQ09ORklH
X0VEQUNfSTU0MDA9bQpDT05GSUdfRURBQ19JN0NPUkU9bQpDT05GSUdfRURBQ19JNTAwMD1tCkNP
TkZJR19FREFDX0k1MTAwPW0KQ09ORklHX0VEQUNfSTczMDA9bQpDT05GSUdfUlRDX0xJQj15CkNP
TkZJR19SVENfQ0xBU1M9eQpDT05GSUdfUlRDX0hDVE9TWVM9eQpDT05GSUdfUlRDX0hDVE9TWVNf
REVWSUNFPSJydGMwIgoKQ09ORklHX1JUQ19JTlRGX1NZU0ZTPXkKQ09ORklHX1JUQ19JTlRGX1BS
T0M9eQpDT05GSUdfUlRDX0lOVEZfREVWPXkKCkNPTkZJR19SVENfRFJWX0RTMTMwNz1tCkNPTkZJ
R19SVENfRFJWX0RTMTM3ND1tCkNPTkZJR19SVENfRFJWX0RTMTY3Mj1tCkNPTkZJR19SVENfRFJW
X01BWDY5MDA9bQpDT05GSUdfUlRDX0RSVl9SUzVDMzcyPW0KQ09ORklHX1JUQ19EUlZfSVNMMTIw
OD1tCkNPTkZJR19SVENfRFJWX1gxMjA1PW0KQ09ORklHX1JUQ19EUlZfUENGODU2Mz1tCkNPTkZJ
R19SVENfRFJWX1BDRjg1ODM9bQpDT05GSUdfUlRDX0RSVl9NNDFUODA9bQpDT05GSUdfUlRDX0RS
Vl9CUTMySz1tCkNPTkZJR19SVENfRFJWX1MzNTM5MEE9bQpDT05GSUdfUlRDX0RSVl9GTTMxMzA9
bQpDT05GSUdfUlRDX0RSVl9SWDg1ODE9bQpDT05GSUdfUlRDX0RSVl9SWDgwMjU9bQoKQ09ORklH
X1JUQ19EUlZfTTQxVDk0PW0KQ09ORklHX1JUQ19EUlZfRFMxMzA1PW0KQ09ORklHX1JUQ19EUlZf
RFMxMzkwPW0KQ09ORklHX1JUQ19EUlZfTUFYNjkwMj1tCkNPTkZJR19SVENfRFJWX1I5NzAxPW0K
Q09ORklHX1JUQ19EUlZfUlM1QzM0OD1tCkNPTkZJR19SVENfRFJWX0RTMzIzND1tCkNPTkZJR19S
VENfRFJWX1BDRjIxMjM9bQoKQ09ORklHX1JUQ19EUlZfQ01PUz15CkNPTkZJR19SVENfRFJWX0RT
MTI4Nj1tCkNPTkZJR19SVENfRFJWX0RTMTUxMT1tCkNPTkZJR19SVENfRFJWX0RTMTU1Mz1tCkNP
TkZJR19SVENfRFJWX0RTMTc0Mj1tCkNPTkZJR19SVENfRFJWX1NUSzE3VEE4PW0KQ09ORklHX1JU
Q19EUlZfTTQ4VDg2PW0KQ09ORklHX1JUQ19EUlZfTTQ4VDM1PW0KQ09ORklHX1JUQ19EUlZfTTQ4
VDU5PW0KQ09ORklHX1JUQ19EUlZfTVNNNjI0Mj1tCkNPTkZJR19SVENfRFJWX0JRNDgwMj1tCkNP
TkZJR19SVENfRFJWX1JQNUMwMT1tCkNPTkZJR19SVENfRFJWX1YzMDIwPW0KQ09ORklHX1JUQ19E
UlZfUENGNTA2MzM9bQoKQ09ORklHX0RNQURFVklDRVM9eQoKQ09ORklHX0lOVEVMX0lPQVRETUE9
bQpDT05GSUdfUENIX0RNQT1tCkNPTkZJR19ETUFfRU5HSU5FPXkKCkNPTkZJR19ORVRfRE1BPXkK
Q09ORklHX0FTWU5DX1RYX0RNQT15CkNPTkZJR19EQ0E9bQpDT05GSUdfVUlPPW0KQ09ORklHX1VJ
T19DSUY9bQpDT05GSUdfVUlPX1BEUlY9bQpDT05GSUdfVUlPX1BEUlZfR0VOSVJRPW0KQ09ORklH
X1VJT19BRUM9bQpDT05GSUdfVUlPX1NFUkNPUzM9bQpDT05GSUdfVUlPX1BDSV9HRU5FUklDPW0K
Q09ORklHX1VJT19ORVRYPW0KQ09ORklHX1ZJUlRJTz1tCkNPTkZJR19WSVJUSU9fUklORz1tCgpD
T05GSUdfVklSVElPX1BDST1tCkNPTkZJR19WSVJUSU9fQkFMTE9PTj1tCgpDT05GSUdfSFlQRVJW
PW0KQ09ORklHX0hZUEVSVl9VVElMUz1tCkNPTkZJR19YODZfUExBVEZPUk1fREVWSUNFUz15CkNP
TkZJR19BQ0VSX1dNST1tCkNPTkZJR19BQ0VSSERGPW0KQ09ORklHX0FTVVNfTEFQVE9QPW0KQ09O
RklHX0RFTExfTEFQVE9QPW0KQ09ORklHX0RFTExfV01JPW0KQ09ORklHX0RFTExfV01JX0FJTz1t
CkNPTkZJR19GVUpJVFNVX0xBUFRPUD1tCkNPTkZJR19BTUlMT19SRktJTEw9bQpDT05GSUdfSFBf
QUNDRUw9bQpDT05GSUdfSFBfV01JPW0KQ09ORklHX01TSV9MQVBUT1A9bQpDT05GSUdfUEFOQVNP
TklDX0xBUFRPUD1tCkNPTkZJR19DT01QQUxfTEFQVE9QPW0KQ09ORklHX1NPTllfTEFQVE9QPW0K
Q09ORklHX1NPTllQSV9DT01QQVQ9eQpDT05GSUdfSURFQVBBRF9MQVBUT1A9bQpDT05GSUdfVEhJ
TktQQURfQUNQST1tCkNPTkZJR19USElOS1BBRF9BQ1BJX0FMU0FfU1VQUE9SVD15CkNPTkZJR19U
SElOS1BBRF9BQ1BJX1ZJREVPPXkKQ09ORklHX1RISU5LUEFEX0FDUElfSE9US0VZX1BPTEw9eQpD
T05GSUdfU0VOU09SU19IREFQUz1tCkNPTkZJR19FRUVQQ19MQVBUT1A9bQpDT05GSUdfQVNVU19X
TUk9bQpDT05GSUdfQVNVU19OQl9XTUk9bQpDT05GSUdfRUVFUENfV01JPW0KQ09ORklHX0FDUElf
V01JPW0KQ09ORklHX01TSV9XTUk9bQpDT05GSUdfVE9QU1RBUl9MQVBUT1A9bQpDT05GSUdfQUNQ
SV9UT1NISUJBPW0KQ09ORklHX1RPU0hJQkFfQlRfUkZLSUxMPW0KQ09ORklHX0FDUElfQ01QQz1t
CkNPTkZJR19JTlRFTF9JUFM9bQpDT05GSUdfU0FNU1VOR19MQVBUT1A9bQpDT05GSUdfTVhNX1dN
ST1tCkNPTkZJR19JTlRFTF9PQUtUUkFJTD1tCgpDT05GSUdfQ0xLRVZUX0k4MjUzPXkKQ09ORklH
X0k4MjUzX0xPQ0s9eQpDT05GSUdfQ0xLQkxEX0k4MjUzPXkKQ09ORklHX0lPTU1VX0FQST15CkNP
TkZJR19JT01NVV9TVVBQT1JUPXkKQ09ORklHX0FNRF9JT01NVT15CkNPTkZJR19ETUFSX1RBQkxF
PXkKQ09ORklHX0lOVEVMX0lPTU1VPXkKQ09ORklHX0lOVEVMX0lPTU1VX0ZMT1BQWV9XQT15CkNP
TkZJR19JUlFfUkVNQVA9eQoKCgpDT05GSUdfRUREPW0KQ09ORklHX0ZJUk1XQVJFX01FTU1BUD15
CkNPTkZJR19FRklfVkFSUz1tCkNPTkZJR19ERUxMX1JCVT1tCkNPTkZJR19EQ0RCQVM9bQpDT05G
SUdfRE1JSUQ9eQpDT05GSUdfSVNDU0lfSUJGVF9GSU5EPXkKQ09ORklHX0lTQ1NJX0lCRlQ9bQoK
Q09ORklHX0RDQUNIRV9XT1JEX0FDQ0VTUz15CkNPTkZJR19FWFQyX0ZTPW0KQ09ORklHX0VYVDJf
RlNfWEFUVFI9eQpDT05GSUdfRVhUMl9GU19QT1NJWF9BQ0w9eQpDT05GSUdfRVhUMl9GU19TRUNV
UklUWT15CkNPTkZJR19FWFQzX0ZTPW0KQ09ORklHX0VYVDNfREVGQVVMVFNfVE9fT1JERVJFRD15
CkNPTkZJR19FWFQzX0ZTX1hBVFRSPXkKQ09ORklHX0VYVDNfRlNfUE9TSVhfQUNMPXkKQ09ORklH
X0VYVDNfRlNfU0VDVVJJVFk9eQpDT05GSUdfRVhUNF9GUz1tCkNPTkZJR19FWFQ0X0ZTX1hBVFRS
PXkKQ09ORklHX0VYVDRfRlNfUE9TSVhfQUNMPXkKQ09ORklHX0VYVDRfRlNfU0VDVVJJVFk9eQpD
T05GSUdfSkJEPW0KQ09ORklHX0pCRDI9bQpDT05GSUdfRlNfTUJDQUNIRT1tCkNPTkZJR19SRUlT
RVJGU19GUz1tCkNPTkZJR19SRUlTRVJGU19GU19YQVRUUj15CkNPTkZJR19SRUlTRVJGU19GU19Q
T1NJWF9BQ0w9eQpDT05GSUdfUkVJU0VSRlNfRlNfU0VDVVJJVFk9eQpDT05GSUdfSkZTX0ZTPW0K
Q09ORklHX0pGU19QT1NJWF9BQ0w9eQpDT05GSUdfSkZTX1NFQ1VSSVRZPXkKQ09ORklHX1hGU19G
Uz1tCkNPTkZJR19YRlNfUVVPVEE9eQpDT05GSUdfWEZTX1BPU0lYX0FDTD15CkNPTkZJR19YRlNf
UlQ9eQpDT05GSUdfR0ZTMl9GUz1tCkNPTkZJR19HRlMyX0ZTX0xPQ0tJTkdfRExNPXkKQ09ORklH
X09DRlMyX0ZTPW0KQ09ORklHX09DRlMyX0ZTX08yQ0I9bQpDT05GSUdfT0NGUzJfRlNfVVNFUlNQ
QUNFX0NMVVNURVI9bQpDT05GSUdfT0NGUzJfRlNfU1RBVFM9eQpDT05GSUdfT0NGUzJfREVCVUdf
TUFTS0xPRz15CkNPTkZJR19CVFJGU19GUz1tCkNPTkZJR19CVFJGU19GU19QT1NJWF9BQ0w9eQpD
T05GSUdfTklMRlMyX0ZTPW0KQ09ORklHX0ZTX1BPU0lYX0FDTD15CkNPTkZJR19FWFBPUlRGUz15
CkNPTkZJR19GSUxFX0xPQ0tJTkc9eQpDT05GSUdfRlNOT1RJRlk9eQpDT05GSUdfRE5PVElGWT15
CkNPTkZJR19JTk9USUZZX1VTRVI9eQpDT05GSUdfRkFOT1RJRlk9eQpDT05GSUdfUVVPVEE9eQpD
T05GSUdfUVVPVEFfTkVUTElOS19JTlRFUkZBQ0U9eQpDT05GSUdfUFJJTlRfUVVPVEFfV0FSTklO
Rz15CkNPTkZJR19RVU9UQV9UUkVFPW0KQ09ORklHX1FGTVRfVjE9bQpDT05GSUdfUUZNVF9WMj1t
CkNPTkZJR19RVU9UQUNUTD15CkNPTkZJR19RVU9UQUNUTF9DT01QQVQ9eQpDT05GSUdfQVVUT0ZT
NF9GUz1tCkNPTkZJR19GVVNFX0ZTPW0KQ09ORklHX0NVU0U9bQpDT05GSUdfR0VORVJJQ19BQ0w9
eQoKQ09ORklHX0ZTQ0FDSEU9bQpDT05GSUdfRlNDQUNIRV9TVEFUUz15CkNPTkZJR19DQUNIRUZJ
TEVTPW0KCkNPTkZJR19JU085NjYwX0ZTPW0KQ09ORklHX0pPTElFVD15CkNPTkZJR19aSVNPRlM9
eQpDT05GSUdfVURGX0ZTPW0KQ09ORklHX1VERl9OTFM9eQoKQ09ORklHX0ZBVF9GUz1tCkNPTkZJ
R19NU0RPU19GUz1tCkNPTkZJR19WRkFUX0ZTPW0KQ09ORklHX0ZBVF9ERUZBVUxUX0NPREVQQUdF
PTQzNwpDT05GSUdfRkFUX0RFRkFVTFRfSU9DSEFSU0VUPSJ1dGY4IgpDT05GSUdfTlRGU19GUz1t
CkNPTkZJR19OVEZTX1JXPXkKCkNPTkZJR19QUk9DX0ZTPXkKQ09ORklHX1BST0NfS0NPUkU9eQpD
T05GSUdfUFJPQ19WTUNPUkU9eQpDT05GSUdfUFJPQ19TWVNDVEw9eQpDT05GSUdfUFJPQ19QQUdF
X01PTklUT1I9eQpDT05GSUdfU1lTRlM9eQpDT05GSUdfVE1QRlM9eQpDT05GSUdfVE1QRlNfUE9T
SVhfQUNMPXkKQ09ORklHX1RNUEZTX1hBVFRSPXkKQ09ORklHX0hVR0VUTEJGUz15CkNPTkZJR19I
VUdFVExCX1BBR0U9eQpDT05GSUdfQ09ORklHRlNfRlM9bQpDT05GSUdfTUlTQ19GSUxFU1lTVEVN
Uz15CkNPTkZJR19BREZTX0ZTPW0KQ09ORklHX0FGRlNfRlM9bQpDT05GSUdfRUNSWVBUX0ZTPW0K
Q09ORklHX0hGU19GUz1tCkNPTkZJR19IRlNQTFVTX0ZTPW0KQ09ORklHX0JFRlNfRlM9bQpDT05G
SUdfQkZTX0ZTPW0KQ09ORklHX0VGU19GUz1tCkNPTkZJR19KRkZTMl9GUz1tCkNPTkZJR19KRkZT
Ml9GU19ERUJVRz0wCkNPTkZJR19KRkZTMl9GU19XUklURUJVRkZFUj15CkNPTkZJR19KRkZTMl9T
VU1NQVJZPXkKQ09ORklHX0pGRlMyX0ZTX1hBVFRSPXkKQ09ORklHX0pGRlMyX0ZTX1BPU0lYX0FD
TD15CkNPTkZJR19KRkZTMl9GU19TRUNVUklUWT15CkNPTkZJR19KRkZTMl9DT01QUkVTU0lPTl9P
UFRJT05TPXkKQ09ORklHX0pGRlMyX1pMSUI9eQpDT05GSUdfSkZGUzJfTFpPPXkKQ09ORklHX0pG
RlMyX1JUSU1FPXkKQ09ORklHX0pGRlMyX0NNT0RFX1BSSU9SSVRZPXkKQ09ORklHX1VCSUZTX0ZT
PW0KQ09ORklHX1VCSUZTX0ZTX0FEVkFOQ0VEX0NPTVBSPXkKQ09ORklHX1VCSUZTX0ZTX0xaTz15
CkNPTkZJR19VQklGU19GU19aTElCPXkKQ09ORklHX0xPR0ZTPW0KQ09ORklHX0NSQU1GUz1tCkNP
TkZJR19TUVVBU0hGUz1tCkNPTkZJR19TUVVBU0hGU19YQVRUUj15CkNPTkZJR19TUVVBU0hGU19a
TElCPXkKQ09ORklHX1NRVUFTSEZTX0xaTz15CkNPTkZJR19TUVVBU0hGU19YWj15CkNPTkZJR19T
UVVBU0hGU19GUkFHTUVOVF9DQUNIRV9TSVpFPTMKQ09ORklHX1ZYRlNfRlM9bQpDT05GSUdfTUlO
SVhfRlM9bQpDT05GSUdfT01GU19GUz1tCkNPTkZJR19RTlg0RlNfRlM9bQpDT05GSUdfUk9NRlNf
RlM9bQpDT05GSUdfUk9NRlNfQkFDS0VEX0JZX0JPVEg9eQpDT05GSUdfUk9NRlNfT05fQkxPQ0s9
eQpDT05GSUdfUk9NRlNfT05fTVREPXkKQ09ORklHX1BTVE9SRT15CkNPTkZJR19TWVNWX0ZTPW0K
Q09ORklHX1VGU19GUz1tCkNPTkZJR19FWE9GU19GUz1tCkNPTkZJR19PUkU9bQpDT05GSUdfTkVU
V09SS19GSUxFU1lTVEVNUz15CkNPTkZJR19ORlNfRlM9bQpDT05GSUdfTkZTX1YyPW0KQ09ORklH
X05GU19WMz1tCkNPTkZJR19ORlNfVjNfQUNMPXkKQ09ORklHX05GU19WND1tCkNPTkZJR19ORlNf
VjRfMT15CkNPTkZJR19QTkZTX0ZJTEVfTEFZT1VUPW0KQ09ORklHX1BORlNfQkxPQ0s9bQpDT05G
SUdfUE5GU19PQkpMQVlPVVQ9bQpDT05GSUdfTkZTX1Y0XzFfSU1QTEVNRU5UQVRJT05fSURfRE9N
QUlOPSJrZXJuZWwub3JnIgpDT05GSUdfTkZTX0ZTQ0FDSEU9eQpDT05GSUdfTkZTX1VTRV9LRVJO
RUxfRE5TPXkKQ09ORklHX05GU0Q9bQpDT05GSUdfTkZTRF9WMl9BQ0w9eQpDT05GSUdfTkZTRF9W
Mz15CkNPTkZJR19ORlNEX1YzX0FDTD15CkNPTkZJR19ORlNEX1Y0PXkKQ09ORklHX0xPQ0tEPW0K
Q09ORklHX0xPQ0tEX1Y0PXkKQ09ORklHX05GU19BQ0xfU1VQUE9SVD1tCkNPTkZJR19ORlNfQ09N
TU9OPXkKQ09ORklHX1NVTlJQQz1tCkNPTkZJR19TVU5SUENfR1NTPW0KQ09ORklHX1NVTlJQQ19C
QUNLQ0hBTk5FTD15CkNPTkZJR19SUENTRUNfR1NTX0tSQjU9bQpDT05GSUdfQ0VQSF9GUz1tCkNP
TkZJR19DSUZTPW0KQ09ORklHX0NJRlNfV0VBS19QV19IQVNIPXkKQ09ORklHX0NJRlNfVVBDQUxM
PXkKQ09ORklHX0NJRlNfWEFUVFI9eQpDT05GSUdfQ0lGU19QT1NJWD15CkNPTkZJR19DSUZTX0RG
U19VUENBTEw9eQpDT05GSUdfQ0lGU19GU0NBQ0hFPXkKQ09ORklHX0NJRlNfQUNMPXkKQ09ORklH
X05DUF9GUz1tCkNPTkZJR19OQ1BGU19QQUNLRVRfU0lHTklORz15CkNPTkZJR19OQ1BGU19JT0NU
TF9MT0NLSU5HPXkKQ09ORklHX05DUEZTX1NUUk9ORz15CkNPTkZJR19OQ1BGU19ORlNfTlM9eQpD
T05GSUdfTkNQRlNfT1MyX05TPXkKQ09ORklHX05DUEZTX05MUz15CkNPTkZJR19OQ1BGU19FWFRS
QVM9eQpDT05GSUdfQ09EQV9GUz1tCkNPTkZJR19BRlNfRlM9bQpDT05GSUdfQUZTX0ZTQ0FDSEU9
eQpDT05GSUdfOVBfRlM9bQpDT05GSUdfOVBfRlNDQUNIRT15CkNPTkZJR185UF9GU19QT1NJWF9B
Q0w9eQpDT05GSUdfTkxTPXkKQ09ORklHX05MU19ERUZBVUxUPSJ1dGY4IgpDT05GSUdfTkxTX0NP
REVQQUdFXzQzNz1tCkNPTkZJR19OTFNfQ09ERVBBR0VfNzM3PW0KQ09ORklHX05MU19DT0RFUEFH
RV83NzU9bQpDT05GSUdfTkxTX0NPREVQQUdFXzg1MD1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODUy
PW0KQ09ORklHX05MU19DT0RFUEFHRV84NTU9bQpDT05GSUdfTkxTX0NPREVQQUdFXzg1Nz1tCkNP
TkZJR19OTFNfQ09ERVBBR0VfODYwPW0KQ09ORklHX05MU19DT0RFUEFHRV84NjE9bQpDT05GSUdf
TkxTX0NPREVQQUdFXzg2Mj1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODYzPW0KQ09ORklHX05MU19D
T0RFUEFHRV84NjQ9bQpDT05GSUdfTkxTX0NPREVQQUdFXzg2NT1tCkNPTkZJR19OTFNfQ09ERVBB
R0VfODY2PW0KQ09ORklHX05MU19DT0RFUEFHRV84Njk9bQpDT05GSUdfTkxTX0NPREVQQUdFXzkz
Nj1tCkNPTkZJR19OTFNfQ09ERVBBR0VfOTUwPW0KQ09ORklHX05MU19DT0RFUEFHRV85MzI9bQpD
T05GSUdfTkxTX0NPREVQQUdFXzk0OT1tCkNPTkZJR19OTFNfQ09ERVBBR0VfODc0PW0KQ09ORklH
X05MU19JU084ODU5Xzg9bQpDT05GSUdfTkxTX0NPREVQQUdFXzEyNTA9bQpDT05GSUdfTkxTX0NP
REVQQUdFXzEyNTE9bQpDT05GSUdfTkxTX0FTQ0lJPW0KQ09ORklHX05MU19JU084ODU5XzE9bQpD
T05GSUdfTkxTX0lTTzg4NTlfMj1tCkNPTkZJR19OTFNfSVNPODg1OV8zPW0KQ09ORklHX05MU19J
U084ODU5XzQ9bQpDT05GSUdfTkxTX0lTTzg4NTlfNT1tCkNPTkZJR19OTFNfSVNPODg1OV82PW0K
Q09ORklHX05MU19JU084ODU5Xzc9bQpDT05GSUdfTkxTX0lTTzg4NTlfOT1tCkNPTkZJR19OTFNf
SVNPODg1OV8xMz1tCkNPTkZJR19OTFNfSVNPODg1OV8xND1tCkNPTkZJR19OTFNfSVNPODg1OV8x
NT1tCkNPTkZJR19OTFNfS09JOF9SPW0KQ09ORklHX05MU19LT0k4X1U9bQpDT05GSUdfTkxTX1VU
Rjg9bQpDT05GSUdfRExNPW0KQ09ORklHX0RMTV9ERUJVRz15CgpDT05GSUdfVFJBQ0VfSVJRRkxB
R1NfU1VQUE9SVD15CkNPTkZJR19QUklOVEtfVElNRT15CkNPTkZJR19ERUZBVUxUX01FU1NBR0Vf
TE9HTEVWRUw9NApDT05GSUdfRU5BQkxFX1dBUk5fREVQUkVDQVRFRD15CkNPTkZJR19FTkFCTEVf
TVVTVF9DSEVDSz15CkNPTkZJR19GUkFNRV9XQVJOPTIwNDgKQ09ORklHX01BR0lDX1NZU1JRPXkK
Q09ORklHX1NUUklQX0FTTV9TWU1TPXkKQ09ORklHX1VOVVNFRF9TWU1CT0xTPXkKQ09ORklHX0RF
QlVHX0ZTPXkKQ09ORklHX0RFQlVHX0tFUk5FTD15CkNPTkZJR19MT0NLVVBfREVURUNUT1I9eQpD
T05GSUdfSEFSRExPQ0tVUF9ERVRFQ1RPUj15CkNPTkZJR19CT09UUEFSQU1fSEFSRExPQ0tVUF9Q
QU5JQ19WQUxVRT0wCkNPTkZJR19CT09UUEFSQU1fU09GVExPQ0tVUF9QQU5JQ19WQUxVRT0wCkNP
TkZJR19QQU5JQ19PTl9PT1BTX1ZBTFVFPTAKQ09ORklHX0RFVEVDVF9IVU5HX1RBU0s9eQpDT05G
SUdfREVGQVVMVF9IVU5HX1RBU0tfVElNRU9VVD0xMjAKQ09ORklHX0JPT1RQQVJBTV9IVU5HX1RB
U0tfUEFOSUNfVkFMVUU9MApDT05GSUdfU0NIRURfREVCVUc9eQpDT05GSUdfVElNRVJfU1RBVFM9
eQpDT05GSUdfU1RBQ0tUUkFDRT15CkNPTkZJR19ERUJVR19CVUdWRVJCT1NFPXkKQ09ORklHX0RF
QlVHX0lORk89eQpDT05GSUdfREVCVUdfTUVNT1JZX0lOSVQ9eQpDT05GSUdfQVJDSF9XQU5UX0ZS
QU1FX1BPSU5URVJTPXkKQ09ORklHX0JPT1RfUFJJTlRLX0RFTEFZPXkKQ09ORklHX1JDVV9DUFVf
U1RBTExfVElNRU9VVD02MApDT05GSUdfVVNFUl9TVEFDS1RSQUNFX1NVUFBPUlQ9eQpDT05GSUdf
Tk9QX1RSQUNFUj15CkNPTkZJR19IQVZFX0ZVTkNUSU9OX1RSQUNFUj15CkNPTkZJR19IQVZFX0ZV
TkNUSU9OX0dSQVBIX1RSQUNFUj15CkNPTkZJR19IQVZFX0ZVTkNUSU9OX0dSQVBIX0ZQX1RFU1Q9
eQpDT05GSUdfSEFWRV9GVU5DVElPTl9UUkFDRV9NQ09VTlRfVEVTVD15CkNPTkZJR19IQVZFX0RZ
TkFNSUNfRlRSQUNFPXkKQ09ORklHX0hBVkVfRlRSQUNFX01DT1VOVF9SRUNPUkQ9eQpDT05GSUdf
SEFWRV9TWVNDQUxMX1RSQUNFUE9JTlRTPXkKQ09ORklHX0hBVkVfQ19SRUNPUkRNQ09VTlQ9eQpD
T05GSUdfUklOR19CVUZGRVI9eQpDT05GSUdfRVZFTlRfVFJBQ0lORz15CkNPTkZJR19FVkVOVF9Q
T1dFUl9UUkFDSU5HX0RFUFJFQ0FURUQ9eQpDT05GSUdfQ09OVEVYVF9TV0lUQ0hfVFJBQ0VSPXkK
Q09ORklHX1JJTkdfQlVGRkVSX0FMTE9XX1NXQVA9eQpDT05GSUdfVFJBQ0lORz15CkNPTkZJR19H
RU5FUklDX1RSQUNFUj15CkNPTkZJR19UUkFDSU5HX1NVUFBPUlQ9eQpDT05GSUdfRlRSQUNFPXkK
Q09ORklHX0JSQU5DSF9QUk9GSUxFX05PTkU9eQpDT05GSUdfQkxLX0RFVl9JT19UUkFDRT15CkNP
TkZJR19IQVZFX0FSQ0hfS0dEQj15CkNPTkZJR19IQVZFX0FSQ0hfS01FTUNIRUNLPXkKQ09ORklH
X1NUUklDVF9ERVZNRU09eQpDT05GSUdfWDg2X1ZFUkJPU0VfQk9PVFVQPXkKQ09ORklHX0VBUkxZ
X1BSSU5USz15CkNPTkZJR19ERUJVR19ST0RBVEE9eQpDT05GSUdfREVCVUdfU0VUX01PRFVMRV9S
T05YPXkKQ09ORklHX0hBVkVfTU1JT1RSQUNFX1NVUFBPUlQ9eQpDT05GSUdfSU9fREVMQVlfVFlQ
RV8wWDgwPTAKQ09ORklHX0lPX0RFTEFZX1RZUEVfMFhFRD0xCkNPTkZJR19JT19ERUxBWV9UWVBF
X1VERUxBWT0yCkNPTkZJR19JT19ERUxBWV9UWVBFX05PTkU9MwpDT05GSUdfSU9fREVMQVlfMFg4
MD15CkNPTkZJR19ERUZBVUxUX0lPX0RFTEFZX1RZUEU9MApDT05GSUdfT1BUSU1JWkVfSU5MSU5J
Tkc9eQoKQ09ORklHX0tFWVM9eQpDT05GSUdfS0VZU19ERUJVR19QUk9DX0tFWVM9eQpDT05GSUdf
U0VDVVJJVFk9eQpDT05GSUdfU0VDVVJJVFlGUz15CkNPTkZJR19TRUNVUklUWV9ORVRXT1JLPXkK
Q09ORklHX1NFQ1VSSVRZX05FVFdPUktfWEZSTT15CkNPTkZJR19TRUNVUklUWV9QQVRIPXkKQ09O
RklHX0xTTV9NTUFQX01JTl9BRERSPTY1NTM2CkNPTkZJR19TRUNVUklUWV9TRUxJTlVYPXkKQ09O
RklHX1NFQ1VSSVRZX1NFTElOVVhfREVWRUxPUD15CkNPTkZJR19TRUNVUklUWV9TRUxJTlVYX0FW
Q19TVEFUUz15CkNPTkZJR19TRUNVUklUWV9TRUxJTlVYX0NIRUNLUkVRUFJPVF9WQUxVRT0xCkNP
TkZJR19TRUNVUklUWV9UT01PWU89eQpDT05GSUdfU0VDVVJJVFlfVE9NT1lPX01BWF9BQ0NFUFRf
RU5UUlk9MjA0OApDT05GSUdfU0VDVVJJVFlfVE9NT1lPX01BWF9BVURJVF9MT0c9MTAyNApDT05G
SUdfU0VDVVJJVFlfVE9NT1lPX1BPTElDWV9MT0FERVI9Ii9zYmluL3RvbW95by1pbml0IgpDT05G
SUdfU0VDVVJJVFlfVE9NT1lPX0FDVElWQVRJT05fVFJJR0dFUj0iL3NiaW4vaW5pdCIKQ09ORklH
X1NFQ1VSSVRZX0FQUEFSTU9SPXkKQ09ORklHX1NFQ1VSSVRZX0FQUEFSTU9SX0JPT1RQQVJBTV9W
QUxVRT0xCkNPTkZJR19ERUZBVUxUX1NFQ1VSSVRZX0RBQz15CkNPTkZJR19ERUZBVUxUX1NFQ1VS
SVRZPSIiCkNPTkZJR19YT1JfQkxPQ0tTPW0KQ09ORklHX0FTWU5DX0NPUkU9bQpDT05GSUdfQVNZ
TkNfTUVNQ1BZPW0KQ09ORklHX0FTWU5DX1hPUj1tCkNPTkZJR19BU1lOQ19QUT1tCkNPTkZJR19B
U1lOQ19SQUlENl9SRUNPVj1tCkNPTkZJR19BU1lOQ19UWF9ESVNBQkxFX1BRX1ZBTF9ETUE9eQpD
T05GSUdfQVNZTkNfVFhfRElTQUJMRV9YT1JfVkFMX0RNQT15CkNPTkZJR19DUllQVE89eQoKQ09O
RklHX0NSWVBUT19GSVBTPXkKQ09ORklHX0NSWVBUT19BTEdBUEk9eQpDT05GSUdfQ1JZUFRPX0FM
R0FQSTI9eQpDT05GSUdfQ1JZUFRPX0FFQUQ9bQpDT05GSUdfQ1JZUFRPX0FFQUQyPXkKQ09ORklH
X0NSWVBUT19CTEtDSVBIRVI9bQpDT05GSUdfQ1JZUFRPX0JMS0NJUEhFUjI9eQpDT05GSUdfQ1JZ
UFRPX0hBU0g9eQpDT05GSUdfQ1JZUFRPX0hBU0gyPXkKQ09ORklHX0NSWVBUT19STkc9bQpDT05G
SUdfQ1JZUFRPX1JORzI9eQpDT05GSUdfQ1JZUFRPX1BDT01QPW0KQ09ORklHX0NSWVBUT19QQ09N
UDI9eQpDT05GSUdfQ1JZUFRPX01BTkFHRVI9eQpDT05GSUdfQ1JZUFRPX01BTkFHRVIyPXkKQ09O
RklHX0NSWVBUT19HRjEyOE1VTD1tCkNPTkZJR19DUllQVE9fTlVMTD1tCkNPTkZJR19DUllQVE9f
UENSWVBUPW0KQ09ORklHX0NSWVBUT19XT1JLUVVFVUU9eQpDT05GSUdfQ1JZUFRPX0NSWVBURD1t
CkNPTkZJR19DUllQVE9fQVVUSEVOQz1tCkNPTkZJR19DUllQVE9fVEVTVD1tCkNPTkZJR19DUllQ
VE9fQUJMS19IRUxQRVJfWDg2PW0KQ09ORklHX0NSWVBUT19HTFVFX0hFTFBFUl9YODY9bQoKQ09O
RklHX0NSWVBUT19DQ009bQpDT05GSUdfQ1JZUFRPX0dDTT1tCkNPTkZJR19DUllQVE9fU0VRSVY9
bQoKQ09ORklHX0NSWVBUT19DQkM9bQpDT05GSUdfQ1JZUFRPX0NUUj1tCkNPTkZJR19DUllQVE9f
Q1RTPW0KQ09ORklHX0NSWVBUT19FQ0I9bQpDT05GSUdfQ1JZUFRPX0xSVz1tCkNPTkZJR19DUllQ
VE9fUENCQz1tCkNPTkZJR19DUllQVE9fWFRTPW0KCkNPTkZJR19DUllQVE9fSE1BQz1tCkNPTkZJ
R19DUllQVE9fWENCQz1tCkNPTkZJR19DUllQVE9fVk1BQz1tCgpDT05GSUdfQ1JZUFRPX0NSQzMy
Qz1tCkNPTkZJR19DUllQVE9fQ1JDMzJDX0lOVEVMPW0KQ09ORklHX0NSWVBUT19HSEFTSD1tCkNP
TkZJR19DUllQVE9fTUQ0PW0KQ09ORklHX0NSWVBUT19NRDU9eQpDT05GSUdfQ1JZUFRPX01JQ0hB
RUxfTUlDPW0KQ09ORklHX0NSWVBUT19STUQxMjg9bQpDT05GSUdfQ1JZUFRPX1JNRDE2MD1tCkNP
TkZJR19DUllQVE9fUk1EMjU2PW0KQ09ORklHX0NSWVBUT19STUQzMjA9bQpDT05GSUdfQ1JZUFRP
X1NIQTE9bQpDT05GSUdfQ1JZUFRPX1NIQTFfU1NTRTM9bQpDT05GSUdfQ1JZUFRPX1NIQTI1Nj1t
CkNPTkZJR19DUllQVE9fU0hBNTEyPW0KQ09ORklHX0NSWVBUT19UR1IxOTI9bQpDT05GSUdfQ1JZ
UFRPX1dQNTEyPW0KQ09ORklHX0NSWVBUT19HSEFTSF9DTE1VTF9OSV9JTlRFTD1tCgpDT05GSUdf
Q1JZUFRPX0FFUz1tCkNPTkZJR19DUllQVE9fQUVTX1g4Nl82ND1tCkNPTkZJR19DUllQVE9fQUVT
X05JX0lOVEVMPW0KQ09ORklHX0NSWVBUT19BTlVCSVM9bQpDT05GSUdfQ1JZUFRPX0FSQzQ9bQpD
T05GSUdfQ1JZUFRPX0JMT1dGSVNIPW0KQ09ORklHX0NSWVBUT19CTE9XRklTSF9DT01NT049bQpD
T05GSUdfQ1JZUFRPX0JMT1dGSVNIX1g4Nl82ND1tCkNPTkZJR19DUllQVE9fQ0FNRUxMSUE9bQpD
T05GSUdfQ1JZUFRPX0NBU1Q1PW0KQ09ORklHX0NSWVBUT19DQVNUNj1tCkNPTkZJR19DUllQVE9f
REVTPW0KQ09ORklHX0NSWVBUT19GQ1JZUFQ9bQpDT05GSUdfQ1JZUFRPX0tIQVpBRD1tCkNPTkZJ
R19DUllQVE9fU0FMU0EyMD1tCkNPTkZJR19DUllQVE9fU0FMU0EyMF9YODZfNjQ9bQpDT05GSUdf
Q1JZUFRPX1NFRUQ9bQpDT05GSUdfQ1JZUFRPX1NFUlBFTlQ9bQpDT05GSUdfQ1JZUFRPX1RFQT1t
CkNPTkZJR19DUllQVE9fVFdPRklTSD1tCkNPTkZJR19DUllQVE9fVFdPRklTSF9DT01NT049bQpD
T05GSUdfQ1JZUFRPX1RXT0ZJU0hfWDg2XzY0PW0KQ09ORklHX0NSWVBUT19UV09GSVNIX1g4Nl82
NF8zV0FZPW0KCkNPTkZJR19DUllQVE9fREVGTEFURT1tCkNPTkZJR19DUllQVE9fWkxJQj1tCkNP
TkZJR19DUllQVE9fTFpPPW0KCkNPTkZJR19DUllQVE9fQU5TSV9DUFJORz1tCkNPTkZJR19DUllQ
VE9fVVNFUl9BUEk9bQpDT05GSUdfQ1JZUFRPX1VTRVJfQVBJX0hBU0g9bQpDT05GSUdfQ1JZUFRP
X1VTRVJfQVBJX1NLQ0lQSEVSPW0KQ09ORklHX0NSWVBUT19IVz15CkNPTkZJR19DUllQVE9fREVW
X1BBRExPQ0s9bQpDT05GSUdfQ1JZUFRPX0RFVl9QQURMT0NLX0FFUz1tCkNPTkZJR19DUllQVE9f
REVWX1BBRExPQ0tfU0hBPW0KQ09ORklHX0hBVkVfS1ZNPXkKQ09ORklHX0hBVkVfS1ZNX0lSUUNI
SVA9eQpDT05GSUdfSEFWRV9LVk1fRVZFTlRGRD15CkNPTkZJR19LVk1fQVBJQ19BUkNISVRFQ1RV
UkU9eQpDT05GSUdfS1ZNX01NSU89eQpDT05GSUdfS1ZNX0FTWU5DX1BGPXkKQ09ORklHX0hBVkVf
S1ZNX01TST15CkNPTkZJR19WSVJUVUFMSVpBVElPTj15CkNPTkZJR19LVk09bQpDT05GSUdfS1ZN
X0lOVEVMPW0KQ09ORklHX0tWTV9BTUQ9bQpDT05GSUdfVkhPU1RfTkVUPW0KQ09ORklHX0JJTkFS
WV9QUklOVEY9eQoKQ09ORklHX1JBSUQ2X1BRPW0KQ09ORklHX0JJVFJFVkVSU0U9eQpDT05GSUdf
R0VORVJJQ19TVFJOQ1BZX0ZST01fVVNFUj15CkNPTkZJR19HRU5FUklDX1NUUk5MRU5fVVNFUj15
CkNPTkZJR19HRU5FUklDX0ZJTkRfRklSU1RfQklUPXkKQ09ORklHX0dFTkVSSUNfUENJX0lPTUFQ
PXkKQ09ORklHX0dFTkVSSUNfSU9NQVA9eQpDT05GSUdfR0VORVJJQ19JTz15CkNPTkZJR19DUkNf
Q0NJVFQ9bQpDT05GSUdfQ1JDMTY9bQpDT05GSUdfQ1JDX1QxMERJRj1tCkNPTkZJR19DUkNfSVRV
X1Q9bQpDT05GSUdfQ1JDMzI9eQpDT05GSUdfQ1JDMzJfU0xJQ0VCWTg9eQpDT05GSUdfQ1JDNz1t
CkNPTkZJR19MSUJDUkMzMkM9bQpDT05GSUdfQ1JDOD1tCkNPTkZJR19aTElCX0lORkxBVEU9eQpD
T05GSUdfWkxJQl9ERUZMQVRFPW0KQ09ORklHX0xaT19DT01QUkVTUz15CkNPTkZJR19MWk9fREVD
T01QUkVTUz15CkNPTkZJR19YWl9ERUM9eQpDT05GSUdfWFpfREVDX1g4Nj15CkNPTkZJR19YWl9E
RUNfUE9XRVJQQz15CkNPTkZJR19YWl9ERUNfSUE2ND15CkNPTkZJR19YWl9ERUNfQVJNPXkKQ09O
RklHX1haX0RFQ19BUk1USFVNQj15CkNPTkZJR19YWl9ERUNfU1BBUkM9eQpDT05GSUdfWFpfREVD
X0JDSj15CkNPTkZJR19ERUNPTVBSRVNTX0daSVA9eQpDT05GSUdfREVDT01QUkVTU19CWklQMj15
CkNPTkZJR19ERUNPTVBSRVNTX0xaTUE9eQpDT05GSUdfREVDT01QUkVTU19YWj15CkNPTkZJR19E
RUNPTVBSRVNTX0xaTz15CkNPTkZJR19HRU5FUklDX0FMTE9DQVRPUj15CkNPTkZJR19SRUVEX1NP
TE9NT049bQpDT05GSUdfUkVFRF9TT0xPTU9OX0RFQzE2PXkKQ09ORklHX1RFWFRTRUFSQ0g9eQpD
T05GSUdfVEVYVFNFQVJDSF9LTVA9bQpDT05GSUdfVEVYVFNFQVJDSF9CTT1tCkNPTkZJR19URVhU
U0VBUkNIX0ZTTT1tCkNPTkZJR19CVFJFRT15CkNPTkZJR19IQVNfSU9NRU09eQpDT05GSUdfSEFT
X0lPUE9SVD15CkNPTkZJR19IQVNfRE1BPXkKQ09ORklHX0NIRUNLX1NJR05BVFVSRT15CkNPTkZJ
R19DUFVfUk1BUD15CkNPTkZJR19EUUw9eQpDT05GSUdfTkxBVFRSPXkKQ09ORklHX0FSQ0hfSEFT
X0FUT01JQzY0X0RFQ19JRl9QT1NJVElWRT15CkNPTkZJR19MUlVfQ0FDSEU9bQpDT05GSUdfQVZF
UkFHRT15CkNPTkZJR19DT1JESUM9bQo=
--0021cc0229c6e12bd004cb3d627e--
