From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: 197b:0250 JMicron JMC250 Gigabit ethernet doesn't work
Date: Tue, 22 Sep 2015 07:04:03 +0800
Message-ID: <20150921230403.M77773@cooldavid.org>
References: <CAH=OcuVNELY_t6Ww5sQm9+HctX=qhSYprWUNWcP-2rxfzEmB=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
To: <druchaty@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:41951 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932814AbbIUXEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 19:04:07 -0400
In-Reply-To: <CAH=OcuVNELY_t6Ww5sQm9+HctX=qhSYprWUNWcP-2rxfzEmB=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear druchaty:

Woule it get link if you set set the speed to 100M?

If it is, then it is a HW-PHY bug, nothing we can do in driver except set the speed to 100M.


On Sat, 19 Sep 2015 21:01:28 +0300, <druchaty@gmail.com> wrote
> [1.] One line summary of the problem: 197b:0250 JMicron JMC250 Gigabit
> ethernet doesn't work
> 
> [2.] Full description of the problem/report:
> Laptop ASUS X52JU can't connect to the router ASUS RT-AC68U via
> ethernet. NetworkManager shows that cable is unplugged. Router has
> Gigabit ethernet ports and laptop doesn't see them. I found that it's
> a bug of the JMC kernel module.
> 
> [4.] Kernel version (from /proc/version):
> Linux version 4.3.0-040300rc1-generic (kernel@gomeisa) (gcc version
> 4.8.4 (Ubuntu 4.8.4-2ubuntu1~14.04) ) #201509160642 SMP Wed Sep 16
> 10:44:16 UTC 2015
> 
> [7.] Environment
> Description: Ubuntu 14.04.3 LTS
> Release: 14.04
> 
> [7.1.] Software
> Linux nick-notebook 4.3.0-040300rc1-generic #201509160642 SMP Wed Sep
> 16 10:44:16 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
> 
> Gnu C                  4.8
> Gnu make               3.81
> binutils               2.24
> util-linux             2.20.1
> mount                  support
> module-init-tools      15
> e2fsprogs              1.42.9
> pcmciautils            018
> PPP                    2.4.5
> Linux C Library        2.19
> Dynamic linker (ldd)   2.19
> Procps                 3.3.9
> Net-tools              1.60
> Kbd                    1.15.5
> Sh-utils               8.21
> wireless-tools         30
> Modules Loaded         nls_iso8859_1 nls_utf8 isofs uas usb_storage
> drbg ansi_cprng ctr ccm rfcomm bnep arc4 ath9k intel_powerclamp
> coretemp ath9k_common ath9k_hw uvcvideo amdkfd videobuf2_vmalloc
> videobuf2_memops amd_iommu_v2 ath radeon videobuf2_core mac80211
> v4l2_common kvm_intel videodev hid_logitech_hidpp media ttm
> drm_kms_helper snd_hda_codec_conexant snd_hda_codec_generic
> snd_hda_codec_hdmi snd_hda_intel snd_hda_codec drm kvm cfg80211
> snd_hda_core snd_seq_midi snd_seq_midi_event snd_rawmidi snd_hwdep
> i2c_algo_bit btusb fb_sys_fops syscopyarea snd_pcm sysfillrect
> sysimgblt snd_seq jmb38x_ms lpc_ich joydev btrtl snd_seq_device
> memstick input_leds btbcm btintel serio_raw bluetooth snd_timer shpchp
> mei_me snd soundcore mei asus_laptop sparse_keymap input_polldev
> parport_pc video ppdev mac_hid lp parport hid_logitech_dj usbhid hid
> psmouse ahci libahci jme mii sdhci_pci sdhci fjes
> 
> [7.2.] Processor information (from /proc/cpuinfo):
> processor : 0
> vendor_id : GenuineIntel
> cpu family : 6
> model : 37
> model name : Intel(R) Core(TM) i3 CPU       M 380  @ 2.53GHz
> stepping : 5
> microcode : 0x2
> cpu MHz : 1066.000
> cache size : 3072 KB
> physical id : 0
> siblings : 4
> core id : 0
> cpu cores : 2
> apicid : 0
> initial apicid : 0
> fpu : yes
> fpu_exception : yes
> cpuid level : 11
> wp : yes
> flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
> rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
> nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3
> cx16 xtpr pdcm pcid sse4_1 sse4_2 popcnt lahf_lm arat dtherm
> tpr_shadow vnmi flexpriority ept vpid
> bugs :
> bogomips : 5053.72
> clflush size : 64
> cache_alignment : 64
> address sizes : 36 bits physical, 48 bits virtual
> power management:
> 
> processor : 1
> vendor_id : GenuineIntel
> cpu family : 6
> model : 37
> model name : Intel(R) Core(TM) i3 CPU       M 380  @ 2.53GHz
> stepping : 5
> microcode : 0x2
> cpu MHz : 1066.000
> cache size : 3072 KB
> physical id : 0
> siblings : 4
> core id : 2
> cpu cores : 2
> apicid : 4
> initial apicid : 4
> fpu : yes
> fpu_exception : yes
> cpuid level : 11
> wp : yes
> flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
> rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
> nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3
> cx16 xtpr pdcm pcid sse4_1 sse4_2 popcnt lahf_lm arat dtherm
> tpr_shadow vnmi flexpriority ept vpid
> bugs :
> bogomips : 5053.72
> clflush size : 64
> cache_alignment : 64
> address sizes : 36 bits physical, 48 bits virtual
> power management:
> 
> processor : 2
> vendor_id : GenuineIntel
> cpu family : 6
> model : 37
> model name : Intel(R) Core(TM) i3 CPU       M 380  @ 2.53GHz
> stepping : 5
> microcode : 0x2
> cpu MHz : 933.000
> cache size : 3072 KB
> physical id : 0
> siblings : 4
> core id : 0
> cpu cores : 2
> apicid : 1
> initial apicid : 1
> fpu : yes
> fpu_exception : yes
> cpuid level : 11
> wp : yes
> flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
> rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
> nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3
> cx16 xtpr pdcm pcid sse4_1 sse4_2 popcnt lahf_lm arat dtherm
> tpr_shadow vnmi flexpriority ept vpid
> bugs :
> bogomips : 5053.72
> clflush size : 64
> cache_alignment : 64
> address sizes : 36 bits physical, 48 bits virtual
> power management:
> 
> processor : 3
> vendor_id : GenuineIntel
> cpu family : 6
> model : 37
> model name : Intel(R) Core(TM) i3 CPU       M 380  @ 2.53GHz
> stepping : 5
> microcode : 0x2
> cpu MHz : 933.000
> cache size : 3072 KB
> physical id : 0
> siblings : 4
> core id : 2
> cpu cores : 2
> apicid : 5
> initial apicid : 5
> fpu : yes
> fpu_exception : yes
> cpuid level : 11
> wp : yes
> flags : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
> pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx
> rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
> nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx est tm2 ssse3
> cx16 xtpr pdcm pcid sse4_1 sse4_2 popcnt lahf_lm arat dtherm
> tpr_shadow vnmi flexpriority ept vpid
> bugs :
> bogomips : 5053.72
> clflush size : 64
> cache_alignment : 64
> address sizes : 36 bits physical, 48 bits virtual
> power management:
> 
> [7.3.] Module information (from /proc/modules):
> nls_iso8859_1 16384 0 - Live 0x0000000000000000
> nls_utf8 16384 0 - Live 0x0000000000000000
> isofs 40960 0 - Live 0x0000000000000000
> uas 24576 0 - Live 0x0000000000000000
> usb_storage 69632 1 uas, Live 0x0000000000000000
> drbg 28672 1 - Live 0x0000000000000000
> ansi_cprng 16384 0 - Live 0x0000000000000000
> ctr 16384 0 - Live 0x0000000000000000
> ccm 20480 0 - Live 0x0000000000000000
> rfcomm 69632 10 - Live 0x0000000000000000
> bnep 20480 2 - Live 0x0000000000000000
> arc4 16384 2 - Live 0x0000000000000000
> ath9k 143360 0 - Live 0x0000000000000000
> intel_powerclamp 16384 0 - Live 0x0000000000000000
> coretemp 16384 0 - Live 0x0000000000000000
> ath9k_common 36864 1 ath9k, Live 0x0000000000000000
> ath9k_hw 466944 2 ath9k,ath9k_common, Live 0x0000000000000000
> uvcvideo 90112 0 - Live 0x0000000000000000
> amdkfd 122880 1 - Live 0x0000000000000000
> videobuf2_vmalloc 16384 1 uvcvideo, Live 0x0000000000000000
> videobuf2_memops 16384 1 videobuf2_vmalloc, Live 0x0000000000000000
> amd_iommu_v2 20480 1 amdkfd, Live 0x0000000000000000
> ath 32768 3 ath9k,ath9k_common,ath9k_hw, Live 0x0000000000000000
> radeon 1499136 4 - Live 0x0000000000000000
> videobuf2_core 49152 1 uvcvideo, Live 0x0000000000000000
> mac80211 724992 1 ath9k, Live 0x0000000000000000
> v4l2_common 16384 1 videobuf2_core, Live 0x0000000000000000
> kvm_intel 163840 0 - Live 0x0000000000000000
> videodev 172032 3 uvcvideo,videobuf2_core,v4l2_common, Live 0x0000000000000000
> hid_logitech_hidpp 20480 0 - Live 0x0000000000000000
> media 24576 2 uvcvideo,videodev, Live 0x0000000000000000
> ttm 94208 1 radeon, Live 0x0000000000000000
> drm_kms_helper 131072 1 radeon, Live 0x0000000000000000
> snd_hda_codec_conexant 24576 1 - Live 0x0000000000000000
> snd_hda_codec_generic 73728 1 snd_hda_codec_conexant, Live 0x0000000000000000
> snd_hda_codec_hdmi 49152 1 - Live 0x0000000000000000
> snd_hda_intel 36864 5 - Live 0x0000000000000000
> snd_hda_codec 135168 4
> snd_hda_codec_conexant,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,
> Live 0x0000000000000000
> drm 352256 7 radeon,ttm,drm_kms_helper, Live 0x0000000000000000
> kvm 507904 1 kvm_intel, Live 0x0000000000000000
> cfg80211 540672 4 ath9k,ath9k_common,ath,mac80211, Live 0x0000000000000000
> snd_hda_core 65536 5
> snd_hda_codec_conexant,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,
> Live 0x0000000000000000
> snd_seq_midi 16384 0 - Live 0x0000000000000000
> snd_seq_midi_event 16384 1 snd_seq_midi, Live 0x0000000000000000
> snd_rawmidi 32768 1 snd_seq_midi, Live 0x0000000000000000
> snd_hwdep 16384 1 snd_hda_codec, Live 0x0000000000000000
> i2c_algo_bit 16384 1 radeon, Live 0x0000000000000000
> btusb 45056 0 - Live 0x0000000000000000
> fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
> syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
> snd_pcm 102400 4
> snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hda_core, Live
> 0x0000000000000000
> sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
> sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
> snd_seq 69632 2 snd_seq_midi,snd_seq_midi_event, Live 0x0000000000000000
> jmb38x_ms 20480 0 - Live 0x0000000000000000
> lpc_ich 24576 0 - Live 0x0000000000000000
> joydev 20480 0 - Live 0x0000000000000000
> btrtl 16384 1 btusb, Live 0x0000000000000000
> snd_seq_device 16384 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 0x0000000000000000
> memstick 20480 1 jmb38x_ms, Live 0x0000000000000000
> input_leds 16384 0 - Live 0x0000000000000000
> btbcm 16384 1 btusb, Live 0x0000000000000000
> btintel 16384 1 btusb, Live 0x0000000000000000
> serio_raw 16384 0 - Live 0x0000000000000000
> bluetooth 516096 25 rfcomm,bnep,btusb,btrtl,btbcm,btintel, Live
> 0x0000000000000000
> snd_timer 32768 2 snd_pcm,snd_seq, Live 0x0000000000000000
> shpchp 36864 0 - Live 0x0000000000000000
> mei_me 28672 0 - Live 0x0000000000000000
> snd 81920 21 snd_hda_codec_conexant,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,
> snd_rawmidi,snd_hwdep,snd_pcm,snd_seq,snd_seq_device,snd_timer, Live 0x0000000000000000 soundcore 16384 1 snd, 
> Live 0x0000000000000000 mei 98304 1 mei_me, Live 0x0000000000000000 asus_laptop 32768 0 - Live 0x0000000000000000
> sparse_keymap 16384 1 asus_laptop, Live 0x0000000000000000
> input_polldev 16384 1 asus_laptop, Live 0x0000000000000000
> parport_pc 36864 0 - Live 0x0000000000000000
> video 36864 1 asus_laptop, Live 0x0000000000000000
> ppdev 20480 0 - Live 0x0000000000000000
> mac_hid 16384 0 - Live 0x0000000000000000
> lp 20480 0 - Live 0x0000000000000000
> parport 49152 3 parport_pc,ppdev,lp, Live 0x0000000000000000
> hid_logitech_dj 20480 0 - Live 0x0000000000000000
> usbhid 49152 0 - Live 0x0000000000000000
> hid 118784 3 hid_logitech_hidpp,hid_logitech_dj,usbhid, Live 0x0000000000000000
> psmouse 122880 0 - Live 0x0000000000000000
> ahci 36864 3 - Live 0x0000000000000000
> libahci 32768 1 ahci, Live 0x0000000000000000
> jme 40960 0 - Live 0x0000000000000000
> mii 16384 1 jme, Live 0x0000000000000000
> sdhci_pci 24576 0 - Live 0x0000000000000000
> sdhci 45056 1 sdhci_pci, Live 0x0000000000000000
> fjes 28672 0 - Live 0x0000000000000000
> 
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> 0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0062-0062 : PNP0C09:00
>     0062-0062 : EC data
>   0064-0064 : keyboard
>   0066-0066 : PNP0C09:00
>     0066-0066 : EC cmd
>   0070-0077 : rtc0
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>     00f0-00f0 : PNP0C04:00
>   0240-0259 : pnp 00:02
>   03c0-03df : vesafb
>   0400-0403 : ACPI PM1a_EVT_BLK
>   0404-0405 : ACPI PM1a_CNT_BLK
>   0408-040b : ACPI PM_TMR
>   0410-0415 : ACPI CPU throttle
>   0420-042f : ACPI GPE0_BLK
>   0430-0433 : iTCO_wdt.0.auto
>   0450-0450 : ACPI PM2_CNT_BLK
>   0460-047f : iTCO_wdt.0.auto
>   0500-057f : pnp 00:00
>   0680-069f : pnp 00:00
> 0cf8-0cff : PCI conf1
> 0d00-ffff : PCI Bus 0000:00
>   164e-164f : pnp 00:00
>   9000-9fff : PCI Bus 0000:05
>     9000-90ff : 0000:05:00.5
>       9000-90ff : jme
>     9100-917f : 0000:05:00.5
>       9100-917f : jme
>   a000-afff : PCI Bus 0000:04
>   b000-bfff : PCI Bus 0000:03
>   c000-cfff : PCI Bus 0000:02
>   d000-dfff : PCI Bus 0000:01
>     d000-d0ff : 0000:01:00.0
>   e000-e01f : 0000:00:1f.3
>   e020-e03f : 0000:00:1f.2
>     e020-e03f : ahci
>   e040-e043 : 0000:00:1f.2
>     e040-e043 : ahci
>   e050-e057 : 0000:00:1f.2
>     e050-e057 : ahci
>   e060-e063 : 0000:00:1f.2
>     e060-e063 : ahci
>   e070-e077 : 0000:00:1f.2
>     e070-e077 : ahci
>   ff00-ff0f : pnp 00:00
>   ffff-ffff : pnp 00:00
>     ffff-ffff : pnp 00:00
> 
> 00000000-00000fff : reserved
> 00001000-0009bbff : System RAM
> 0009bc00-0009ffff : reserved
> 000a0000-000bffff : PCI Bus 0000:00
> 000c0000-000cf1ff : Video ROM
> 000d0000-000d3fff : PCI Bus 0000:00
> 000d4000-000d7fff : PCI Bus 0000:00
> 000d8000-000dbfff : PCI Bus 0000:00
> 000dc000-000dffff : PCI Bus 0000:00
> 000e0000-000fffff : reserved
>   000f0000-000fffff : System ROM
> 00100000-becf0fff : System RAM
>   01000000-017b830b : Kernel code
>   017b830c-01d3c3bf : Kernel data
>   01eb3000-01ff7fff : Kernel bss
> becf1000-bed35fff : ACPI Non-volatile Storage
> bed36000-bed46fff : reserved
> bed47000-bed58fff : ACPI Non-volatile Storage
> bed59000-bed61fff : reserved
> bed62000-bed69fff : ACPI Non-volatile Storage
> bed6a000-bed82fff : reserved
> bed83000-bed83fff : ACPI Non-volatile Storage
> bed84000-bed99fff : reserved
> bed9a000-bed9cfff : ACPI Non-volatile Storage
> bed9d000-bed9efff : reserved
> bed9f000-bed9ffff : ACPI Non-volatile Storage
> beda0000-beda3fff : reserved
> beda4000-beda6fff : ACPI Tables
> beda7000-bedabfff : reserved
> bedac000-bedb9fff : ACPI Non-volatile Storage
> bedba000-bedcffff : reserved
> bedd0000-bedd1fff : ACPI Non-volatile Storage
> bedd2000-bfffffff : reserved
> c0000000-feafffff : PCI Bus 0000:00
>   c0000000-d00fffff : PCI Bus 0000:01
>     c0000000-cfffffff : 0000:01:00.0
>     d0000000-d001ffff : 0000:01:00.0
>     d0020000-d003ffff : 0000:01:00.0
>     d0040000-d0043fff : 0000:01:00.1
>       d0040000-d0043fff : ICH HD audio
>   d0200000-d15fffff : PCI Bus 0000:05
>     d0200000-d0203fff : 0000:05:00.5
>       d0200000-d0203fff : jme
>     d0204000-d02040ff : 0000:05:00.4
>     d0205000-d02050ff : 0000:05:00.3
>       d0205000-d02050ff : jmb38x_ms
>     d0206000-d02060ff : 0000:05:00.2
>     d0207000-d02070ff : 0000:05:00.0
>       d0207000-d02070ff : mmc0
>   d1600000-d29fffff : PCI Bus 0000:04
>   d2a00000-d3dfffff : PCI Bus 0000:03
>     d2a00000-d2a0ffff : 0000:03:00.0
>       d2a00000-d2a0ffff : ath9k
>   d3e00000-d51fffff : PCI Bus 0000:02
>   d5200000-d5203fff : 0000:00:1b.0
>     d5200000-d5203fff : ICH HD audio
>   d5205000-d52050ff : 0000:00:1f.3
>   d5206000-d52067ff : 0000:00:1f.2
>     d5206000-d52067ff : ahci
>   d5207000-d52073ff : 0000:00:1d.0
>     d5207000-d52073ff : ehci_hcd
>   d5208000-d52083ff : 0000:00:1a.0
>     d5208000-d52083ff : ehci_hcd
>   d520a000-d520a00f : 0000:00:16.0
>     d520a000-d520a00f : mei_me
>   d520b000-d520bfff : pnp 00:05
>   d5300000-d54fffff : PCI Bus 0000:02
>   d5500000-d56fffff : PCI Bus 0000:03
>   d5700000-d58fffff : PCI Bus 0000:04
>   d5900000-d5afffff : PCI Bus 0000:05
>   e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
>     e0000000-efffffff : reserved
>       e0000000-efffffff : pnp 00:05
> fec00000-fec00fff : reserved
>   fec00000-fec003ff : IOAPIC 0
> fed00000-fed003ff : HPET 0
>   fed00000-fed003ff : PNP0103:00
> fed10000-fed13fff : reserved
>   fed10000-fed13fff : pnp 00:05
> fed18000-fed19fff : reserved
>   fed18000-fed18fff : pnp 00:05
>   fed19000-fed19fff : pnp 00:05
> fed1c000-fed1ffff : reserved
>   fed1c000-fed1ffff : pnp 00:05
>     fed1f410-fed1f414 : iTCO_wdt.0.auto
> fed20000-fed3ffff : pnp 00:05
> fed45000-fed8ffff : pnp 00:05
> fee00000-fee00fff : Local APIC
>   fee00000-fee00fff : reserved
> ff000000-ffffffff : INT0800:00
>   ffa00000-ffbfffff : reserved
>   ffe00000-ffffffff : reserved
> 100000000-1fbffffff : System RAM
> 1fc000000-1ffffffff : reserved
> 200000000-23bffffff : System RAM
> 
> [7.5.] PCI information ('lspci -vvv' as root)
> 00:00.0 Host bridge: Intel Corporation Core Processor DRAM Controller (rev 18)
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR- INTx-
> Latency: 0
> Capabilities: [e0] Vendor Specific Information: Len=0c <?>
> 
> 00:01.0 PCI bridge: Intel Corporation Core Processor PCI Express x16
> Root Port (rev 18) (prog-if 00 [Normal decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> I/O behind bridge: 0000d000-0000dfff
> Memory behind bridge: c0000000-d00fffff
> Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [88] Subsystem: ASUSTeK Computer Inc. Device 1c77
> Capabilities: [80] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0100c  Data: 4151
> Capabilities: [a0] Express (v2) Root Port (Slot+), MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE+
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency
> L0s <256ns, L1 <4us
> ClockPM- Surprise- LLActRep- BwNot+
> LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
> Slot #17, PowerLimit 75.000W; Interlock- NoCompl+
> SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
> Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> Changed: MRL- PresDet+ LinkState-
> RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
> RootCap: CRSVisible-
> RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF
> Not Supported ARIFwd-
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF
> Disabled ARIFwd-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [100 v1] Virtual Channel
> Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
> Arb: Fixed- WRR32- WRR64- WRR128-
> Ctrl: ArbSelect=Fixed
> Status: InProgress-
> VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
> Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> Status: NegoPending- InProgress-
> Kernel driver in use: pcieport
> 
> 00:16.0 Communication controller: Intel Corporation 5 Series/3400
> Series Chipset HECI Controller (rev 06)
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Interrupt: pin A routed to IRQ 30
> Region 0: Memory at d520a000 (64-bit, non-prefetchable) [size=16]
> Capabilities: [50] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [8c] MSI: Enable+ Count=1/1 Maskable- 64bit+
> Address: 00000000fee0f00c  Data: 4123
> Kernel driver in use: mei_me
> 
> 00:1a.0 USB controller: Intel Corporation 5 Series/3400 Series Chipset
> USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Interrupt: pin A routed to IRQ 16
> Region 0: Memory at d5208000 (32-bit, non-prefetchable) [size=1K]
> Capabilities: [50] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [58] Debug port: BAR=1 offset=00a0
> Capabilities: [98] PCI Advanced Features
> AFCap: TP+ FLR+
> AFCtrl: FLR-
> AFStatus: TP+
> Kernel driver in use: ehci-pci
> 
> 00:1b.0 Audio device: Intel Corporation 5 Series/3400 Series Chipset
> High Definition Audio (rev 06)
> Subsystem: ASUSTeK Computer Inc. Device 1643
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 31
> Region 0: Memory at d5200000 (64-bit, non-prefetchable) [size=16K]
> Capabilities: [50] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
> Address: 00000000fee0f00c  Data: 4143
> Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> Capabilities: [100 v1] Virtual Channel
> Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
> Arb: Fixed- WRR32- WRR64- WRR128-
> Ctrl: ArbSelect=Fixed
> Status: InProgress-
> VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> Status: NegoPending- InProgress-
> VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> Ctrl: Enable+ ID=1 ArbSelect=Fixed TC/VC=02
> Status: NegoPending- InProgress-
> Capabilities: [130 v1] Root Complex Link
> Desc: PortNumber=0f ComponentID=00 EltType=Config
> Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
> LinkType=MemMapped LinkValid+
> Addr: 00000000fed1c000
> Kernel driver in use: snd_hda_intel
> 
> 00:1c.0 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI
> Express Root Port 1 (rev 06) (prog-if 00 [Normal decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> I/O behind bridge: 0000c000-0000cfff
> Memory behind bridge: d3e00000-d51fffff
> Prefetchable memory behind bridge: 00000000d5300000-00000000d54fffff
> Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE+
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s <1us, L1 <4us
> ClockPM- Surprise- LLActRep+ BwNot-
> LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk-
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
> Slot #0, PowerLimit 10.000W; Interlock- NoCompl+
> SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
> Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> Changed: MRL- PresDet- LinkState-
> RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
> RootCap: CRSVisible-
> RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF Not
> Supported ARIFwd-
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF
> Disabled ARIFwd-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0100c  Data: 4171
> Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 1c77
> Capabilities: [a0] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Kernel driver in use: pcieport
> 
> 00:1c.1 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI
> Express Root Port 2 (rev 06) (prog-if 00 [Normal decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> I/O behind bridge: 0000b000-0000bfff
> Memory behind bridge: d2a00000-d3dfffff
> Prefetchable memory behind bridge: 00000000d5500000-00000000d56fffff
> Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE+
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s <256ns, L1 <4us
> ClockPM- Surprise- LLActRep+ BwNot-
> LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
> BWMgmt- ABWMgmt-
> SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
> Slot #1, PowerLimit 10.000W; Interlock- NoCompl+
> SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
> Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> Changed: MRL- PresDet- LinkState-
> RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
> RootCap: CRSVisible-
> RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF Not
> Supported ARIFwd-
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF
> Disabled ARIFwd-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0500c  Data: 4191
> Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 1c77
> Capabilities: [a0] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Kernel driver in use: pcieport
> 
> 00:1c.2 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI
> Express Root Port 3 (rev 06) (prog-if 00 [Normal decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
> I/O behind bridge: 0000a000-0000afff
> Memory behind bridge: d1600000-d29fffff
> Prefetchable memory behind bridge: 00000000d5700000-00000000d58fffff
> Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE+
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s <1us, L1 <4us
> ClockPM- Surprise- LLActRep+ BwNot-
> LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk-
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
> Slot #2, PowerLimit 10.000W; Interlock- NoCompl+
> SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
> Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
> Changed: MRL- PresDet- LinkState-
> RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
> RootCap: CRSVisible-
> RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF Not
> Supported ARIFwd-
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF
> Disabled ARIFwd-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0100c  Data: 41b1
> Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 1c77
> Capabilities: [a0] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Kernel driver in use: pcieport
> 
> 00:1c.5 PCI bridge: Intel Corporation 5 Series/3400 Series Chipset PCI
> Express Root Port 6 (rev 06) (prog-if 00 [Normal decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
> I/O behind bridge: 00009000-00009fff
> Memory behind bridge: d0200000-d15fffff
> Prefetchable memory behind bridge: 00000000d5900000-00000000d5afffff
> Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [40] Express (v2) Root Port (Slot+), MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0
> ExtTag- RBE+
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #6, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s <256ns, L1 <4us
> ClockPM- Surprise- LLActRep+ BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
> BWMgmt- ABWMgmt-
> SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
> Slot #5, PowerLimit 10.000W; Interlock- NoCompl+
> SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
> Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
> SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
> Changed: MRL- PresDet- LinkState-
> RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ CRSVisible-
> RootCap: CRSVisible-
> RootSta: PME ReqID 0000, PMEStatus- PMEPending-
> DevCap2: Completion Timeout: Range BC, TimeoutDis+, LTR-, OBFF Not
> Supported ARIFwd-
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF
> Disabled ARIFwd-
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0500c  Data: 41d1
> Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Device 1c77
> Capabilities: [a0] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Kernel driver in use: pcieport
> 
> 00:1d.0 USB controller: Intel Corporation 5 Series/3400 Series Chipset
> USB2 Enhanced Host Controller (rev 06) (prog-if 20 [EHCI])
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Interrupt: pin A routed to IRQ 23
> Region 0: Memory at d5207000 (32-bit, non-prefetchable) [size=1K]
> Capabilities: [50] Power Management version 2
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [58] Debug port: BAR=1 offset=00a0
> Capabilities: [98] PCI Advanced Features
> AFCap: TP+ FLR+
> AFCtrl: FLR-
> AFStatus: TP-
> Kernel driver in use: ehci-pci
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev a6)
> (prog-if 01 [Subtractive decode])
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Bus: primary=00, secondary=06, subordinate=06, sec-latency=32
> I/O behind bridge: 0000f000-00000fff
> Memory behind bridge: fff00000-000fffff
> Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR-
> BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
> PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
> Capabilities: [50] Subsystem: ASUSTeK Computer Inc. Device 1c77
> 
> 00:1f.0 ISA bridge: Intel Corporation Mobile 5 Series Chipset LPC
> Interface Controller (rev 06)
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Capabilities: [e0] Vendor Specific Information: Len=10 <?>
> Kernel driver in use: lpc_ich
> 
> 00:1f.2 SATA controller: Intel Corporation 5 Series/3400 Series
> Chipset 4 port SATA AHCI Controller (rev 06) (prog-if 01 [AHCI 1.0])
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> Interrupt: pin B routed to IRQ 29
> Region 0: I/O ports at e070 [size=8]
> Region 1: I/O ports at e060 [size=4]
> Region 2: I/O ports at e050 [size=8]
> Region 3: I/O ports at e040 [size=4]
> Region 4: I/O ports at e020 [size=32]
> Region 5: Memory at d5206000 (32-bit, non-prefetchable) [size=2K]
> Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
> Address: fee0a00c  Data: 4172
> Capabilities: [70] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [a8] SATA HBA v1.0 BAR4 Offset=00000004
> Capabilities: [b0] PCI Advanced Features
> AFCap: TP+ FLR+
> AFCtrl: FLR-
> AFStatus: TP-
> Kernel driver in use: ahci
> 
> 00:1f.3 SMBus: Intel Corporation 5 Series/3400 Series Chipset SMBus
> Controller (rev 06)
> Subsystem: ASUSTeK Computer Inc. Device 1c77
> Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Interrupt: pin C routed to IRQ 4
> Region 0: Memory at d5205000 (64-bit, non-prefetchable) [size=256]
> Region 4: I/O ports at e000 [size=32]
> 
> 01:00.0 VGA compatible controller: Advanced Micro Devices, Inc.
> [AMD/ATI] Robson CE [Radeon HD 6370M/7370M] (prog-if 00 [VGA
> controller])
> Subsystem: ASUSTeK Computer Inc. Radeon HD 6370M
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 33
> Region 0: Memory at c0000000 (64-bit, prefetchable) [size=256M]
> Region 2: Memory at d0020000 (64-bit, non-prefetchable) [size=128K]
> Region 4: I/O ports at d000 [size=256]
> Expansion ROM at d0000000 [disabled] [size=128K]
> Capabilities: [50] Power Management version 3
> Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
> DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
> ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> MaxPayload 128 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency
> L0s <64ns, L1 <1us
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF
> Not Supported
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> Address: 00000000fee0100c  Data: 41c2
> Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> Kernel driver in use: radeon
> 
> 01:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Cedar
> HDMI Audio [Radeon HD 5400/6300 Series]
> Subsystem: ASUSTeK Computer Inc. Device aa68
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin B routed to IRQ 32
> Region 0: Memory at d0040000 (64-bit, non-prefetchable) [size=16K]
> Capabilities: [50] Power Management version 3
> Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
> DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
> ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> MaxPayload 128 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency
> L0s <64ns, L1 <1us
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF
> Not Supported
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> Address: 00000000fee0f00c  Data: 4153
> Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
> Kernel driver in use: snd_hda_intel
> 
> 03:00.0 Network controller: Qualcomm Atheros AR9285 Wireless Network
> Adapter (PCI-Express) (rev 01)
> Subsystem: AzureWave AW-NE785 / AW-NE785H 802.11bgn Wireless Full or
> Half-size Mini PCIe Card
> Physical Slot: 1
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 17
> Region 0: Memory at d2a00000 (64-bit, non-prefetchable) [size=64K]
> Capabilities: [40] Power Management version 3
> Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit-
> Address: 00000000  Data: 0000
> Capabilities: [60] Express (v2) Legacy Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s <512ns, L1 <64us
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
> Not Supported
> DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
> LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
> Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
> Compliance De-emphasis: -6dB
> LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
> EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
> Capabilities: [100 v1] Advanced Error Reporting
> UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
> UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
> CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
> AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> Capabilities: [140 v1] Virtual Channel
> Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
> Arb: Fixed- WRR32- WRR64- WRR128-
> Ctrl: ArbSelect=Fixed
> Status: InProgress-
> VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
> Status: NegoPending- InProgress-
> Capabilities: [160 v1] Device Serial Number 00-15-17-ff-ff-24-14-12
> Capabilities: [170 v1] Power Budgeting <?>
> Kernel driver in use: ath9k
> 
> 05:00.0 System peripheral: JMicron Technology Corp. SD/MMC Host
> Controller (rev 80)
> Subsystem: ASUSTeK Computer Inc. Device 1a07
> Physical Slot: 5
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin B routed to IRQ 18
> Region 0: Memory at d0207000 (32-bit, non-prefetchable) [size=256]
> Capabilities: [a4] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [80] Express (v1) Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s unlimited, L1 unlimited
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
> Address: fffffffc  Data: 0000
> Kernel driver in use: sdhci-pci
> 
> 05:00.2 SD Host controller: JMicron Technology Corp. Standard SD Host
> Controller (rev 80) (prog-if 01)
> Subsystem: ASUSTeK Computer Inc. Device 1a07
> Physical Slot: 5
> Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Interrupt: pin B routed to IRQ 0
> Region 0: Memory at d0206000 (32-bit, non-prefetchable) [size=256]
> Capabilities: [a4] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [80] Express (v1) Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s unlimited, L1 unlimited
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
> Address: fffffffc  Data: 0000
> 
> 05:00.3 System peripheral: JMicron Technology Corp. MS Host Controller (rev 80)
> Subsystem: ASUSTeK Computer Inc. Device 1a07
> Physical Slot: 5
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin B routed to IRQ 18
> Region 0: Memory at d0205000 (32-bit, non-prefetchable) [size=256]
> Capabilities: [a4] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [80] Express (v1) Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s unlimited, L1 unlimited
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
> Address: fffffffc  Data: 0000
> Kernel driver in use: jmb38x_ms
> 
> 05:00.4 System peripheral: JMicron Technology Corp. xD Host Controller (rev 80)
> Subsystem: ASUSTeK Computer Inc. Device 1a07
> Physical Slot: 5
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin B routed to IRQ 4
> Region 0: Memory at d0204000 (32-bit, non-prefetchable) [size=256]
> Capabilities: [a4] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [80] Express (v1) Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 128 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
> LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s unlimited, L1 unlimited
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
> Address: fffffffc  Data: 0000
> 
> 05:00.5 Ethernet controller: JMicron Technology Corp. JMC250 PCI
> Express Gigabit Ethernet Controller (rev 03)
> Subsystem: ASUSTeK Computer Inc. Device 1905
> Physical Slot: 5
> Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
> Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0, Cache Line Size: 64 bytes
> Interrupt: pin A routed to IRQ 34
> Region 0: Memory at d0200000 (32-bit, non-prefetchable) [size=16K]
> Region 2: I/O ports at 9100 [size=128]
> Region 3: I/O ports at 9000 [size=256]
> Capabilities: [68] Power Management version 3
> Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
> Capabilities: [50] Express (v1) Legacy Endpoint, MSI 00
> DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
> ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
> DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> MaxPayload 128 bytes, MaxReadReq 512 bytes
> DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
> L0s unlimited, L1 unlimited
> ClockPM- Surprise- LLActRep- BwNot-
> LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
> ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
> Capabilities: [40] MSI-X: Enable- Count=8 Masked-
> Vector table: BAR=0 offset=00002000
> PBA: BAR=0 offset=00003000
> Capabilities: [70] MSI: Enable+ Count=1/8 Maskable+ 64bit+
> Address: 00000000fee0100c  Data: 4163
> Masking: 000000fe  Pending: 00000000
> Kernel driver in use: jme
> 
> ff:00.0 Host bridge: Intel Corporation Core Processor QuickPath
> Architecture Generic Non-core Registers (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> ff:00.1 Host bridge: Intel Corporation Core Processor QuickPath
> Architecture System Address Decoder (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> ff:02.0 Host bridge: Intel Corporation Core Processor QPI Link 0 (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> ff:02.1 Host bridge: Intel Corporation Core Processor QPI Physical 0 (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> ff:02.2 Host bridge: Intel Corporation Core Processor Reserved (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> ff:02.3 Host bridge: Intel Corporation Core Processor Reserved (rev 05)
> Subsystem: Intel Corporation Device 8086
> Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
> Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> Latency: 0
> 
> [7.6.] SCSI information (from /proc/scsi/scsi)
> Attached devices:
> Host: scsi0 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: ST9500325AS      Rev: SDM1
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> Host: scsi1 Channel: 00 Id: 00 Lun: 00
>   Vendor: PIONEER  Model: DVD-RW DVRTD10RS Rev: 1.00
>   Type:   CD-ROM                           ANSI  SCSI revision: 05
> 
> [X.] Other notes, patches, fixes, workarounds:
> The following allows 100 Mbps speed: sudo ethtool -s eth0 speed 100 duplex full
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Guo-Fu Tseng
