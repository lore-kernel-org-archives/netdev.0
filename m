From: Tony <tony.buckley@internode.on.net>
Subject: PROBLEM:
Date: Tue, 15 Nov 2016 18:45:01 +1100
Message-ID: <859f1127-95bb-b273-da32-0375bdc85189@internode.on.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:59562 "EHLO
        ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752022AbcKOHpG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 02:45:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am reporting this as requested below:

Anthony Buckley, the issue you are reporting is an upstream one. Could
you please report this problem following the instructions verbatim at
https://wiki.ubuntu.com/Bugs/Upstream/kernel to the appropriate mailing
list (TO: Eric Dumazet, and David S. Miller, CC netdev)?

Apologies if I have sent this to the wrong area(s). I'm a bit new to this.


Kernel.org format information

[1] One line summary of the problem:

Network scanner not detected by xsane after kernel upgrade

[2] Full description of the problem/report:

The scanner on my 'Epson WF-3520' multi-function is no longer detected 
by xsane
(and other scan apps.) when connected wirelessly to the network.
The problem occurs on a Dell 64 bit desktop, an Asus 64 bit laptop and a 
Medion 32 bit laptop.
Printing works normally and the scanner is detected if connected via a 
USB cable.
To reproduce, I turn on the scanner and start xsane. There is some delay 
and then
a 'no devices found' window appears.

[3] Keywords. Leave blank.

[4] Kernel version

cat /proc/version
Linux version 4.9.0-040900rc4-generic (kernel@tangerine) (gcc version 
6.2.0 20161005 (Ubuntu 6.2.0-5ubuntu12) ) #201611052031 SMP Sun Nov 6 
00:33:05 UTC 2016

[5] Not applicable

[6] Not applicable

[7] Environment

lsb_release -rd
Description:    Ubuntu 16.04.1 LTS
Release:        16.04

[7.1] Software (add the output of the ver_linux script here)

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux Handel 4.9.0-040900rc4-generic #201611052031 SMP Sun Nov 6 
00:33:05 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

GNU C                   5.4.0
GNU Make                4.1
Binutils                2.26.1
Util-linux              2.27.1
Mount                   2.27.1
Module-init-tools       22
E2fsprogs               1.42.13
Pcmciautils             018
PPP                     2.4.7
Linux C Library         2.23
Dynamic linker (ldd)    2.23
Linux C++ Library       6.0.21
Procps                  3.3.10
Net-tools               1.60
Kbd                     1.15.5
Console-tools           1.15.5
Sh-utils                8.25
Udev                    229
Wireless-tools          30
Modules Loaded          amdgpu amd_iommu_v2 amdkfd autofs4 binfmt_misc 
bluetooth bnep btbcm btintel btrtl btusb coretemp crc_itu_t dcdbas 
dell_smm_hwmon drm drm_kms_helper e1000e edac_core fb_sys_fops 
firewire_core firewire_ohci fjes gpio_ich hid hid_generic i2c_algo_bit 
i5500_temp i7core_edac input_leds intel_cstate ip6table_filter 
ip6_tables ip6t_REJECT ip6t_rt iptable_filter ip_tables ipt_REJECT 
irqbypass joydev kvm kvm_intel lp lpc_ich mac_hid nf_conntrack 
nf_conntrack_broadcast nf_conntrack_ftp nf_conntrack_ipv4 
nf_conntrack_ipv6 nf_conntrack_netbios_ns nf_defrag_ipv4 nf_defrag_ipv6 
nf_log_common nf_log_ipv4 nf_log_ipv6 nf_nat nf_nat_ftp nf_reject_ipv4 
nf_reject_ipv6 parport parport_pc pata_acpi ppdev pps_core psmouse ptp 
radeon rfcomm serio_raw shpchp snd snd_hda_codec snd_hda_codec_generic 
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_core snd_hda_intel 
snd_hwdep snd_pcm snd_rawmidi snd_seq snd_seq_device snd_seq_midi 
snd_seq_midi_event snd_timer soundcore syscopyarea sysfillrect sysimgblt 
ttm uas usbhid usb_storage x_tables xt_addrtype xt_conntrack xt_hl 
xt_limit xt_LOG xt_multiport xt_recent xt_tcpudp

[7.2] Processor information

cat /proc/cpuinfo
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 0
cpu cores    : 4
apicid        : 0
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5320.35
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 1
cpu cores    : 4
apicid        : 2
initial apicid    : 2
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 2
cpu cores    : 4
apicid        : 4
initial apicid    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.74
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 3
cpu cores    : 4
apicid        : 6
initial apicid    : 6
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.71
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 4
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 2000.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 0
cpu cores    : 4
apicid        : 1
initial apicid    : 1
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.73
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 5
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 1
cpu cores    : 4
apicid        : 3
initial apicid    : 3
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.74
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 6
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 2133.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 2
cpu cores    : 4
apicid        : 5
initial apicid    : 5
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.73
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

processor    : 7
vendor_id    : GenuineIntel
cpu family    : 6
model        : 26
model name    : Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz
stepping    : 4
microcode    : 0x11
cpu MHz        : 1600.000
cache size    : 8192 KB
physical id    : 0
siblings    : 8
core id        : 3
cpu cores    : 4
apicid        : 7
initial apicid    : 7
fpu        : yes
fpu_exception    : yes
cpuid level    : 11
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca 
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology 
nonstop_tsc aperfmperf eagerfpu pni dtes64 monitor ds_cpl vmx est tm2 
ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm tpr_shadow vnmi 
flexpriority ept vpid dtherm ida
bugs        :
bogomips    : 5319.72
clflush size    : 64
cache_alignment    : 64
address sizes    : 36 bits physical, 48 bits virtual
power management:

[7.3] Module information

cat /proc/modules
rfcomm 77824 12 - Live 0x0000000000000000
bnep 20480 2 - Live 0x0000000000000000
btusb 45056 0 - Live 0x0000000000000000
btrtl 16384 1 btusb, Live 0x0000000000000000
input_leds 16384 0 - Live 0x0000000000000000
snd_hda_codec_realtek 86016 1 - Live 0x0000000000000000
joydev 20480 0 - Live 0x0000000000000000
btbcm 16384 1 btusb, Live 0x0000000000000000
snd_hda_codec_generic 73728 1 snd_hda_codec_realtek, Live 0x0000000000000000
snd_hda_codec_hdmi 45056 1 - Live 0x0000000000000000
btintel 16384 1 btusb, Live 0x0000000000000000
bluetooth 561152 41 rfcomm,bnep,btusb,btrtl,btbcm,btintel, Live 
0x0000000000000000
snd_hda_intel 36864 5 - Live 0x0000000000000000
snd_hda_codec 135168 4 
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel, 
Live 0x0000000000000000
snd_hda_core 86016 5 
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, 
Live 0x0000000000000000
snd_hwdep 16384 1 snd_hda_codec, Live 0x0000000000000000
coretemp 16384 0 - Live 0x0000000000000000
snd_pcm 114688 4 
snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hda_core, Live 
0x0000000000000000
kvm_intel 196608 0 - Live 0x0000000000000000
snd_seq_midi 16384 0 - Live 0x0000000000000000
snd_seq_midi_event 16384 1 snd_seq_midi, Live 0x0000000000000000
kvm 598016 1 kvm_intel, Live 0x0000000000000000
snd_rawmidi 32768 1 snd_seq_midi, Live 0x0000000000000000
gpio_ich 16384 0 - Live 0x0000000000000000
snd_seq 65536 2 snd_seq_midi,snd_seq_midi_event, Live 0x0000000000000000
snd_seq_device 16384 3 snd_seq_midi,snd_rawmidi,snd_seq, Live 
0x0000000000000000
snd_timer 32768 2 snd_pcm,snd_seq, Live 0x0000000000000000
dcdbas 16384 0 - Live 0x0000000000000000
irqbypass 16384 1 kvm, Live 0x0000000000000000
snd 86016 21 
snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_rawmidi,snd_seq,snd_seq_device,snd_timer, 
Live 0x0000000000000000
soundcore 16384 1 snd, Live 0x0000000000000000
dell_smm_hwmon 16384 0 - Live 0x0000000000000000
intel_cstate 16384 0 - Live 0x0000000000000000
serio_raw 16384 0 - Live 0x0000000000000000
shpchp 36864 0 - Live 0x0000000000000000
lpc_ich 24576 0 - Live 0x0000000000000000
i5500_temp 16384 0 - Live 0x0000000000000000
i7core_edac 24576 0 - Live 0x0000000000000000
edac_core 53248 2 i7core_edac, Live 0x0000000000000000
mac_hid 16384 0 - Live 0x0000000000000000
binfmt_misc 20480 1 - Live 0x0000000000000000
ip6t_REJECT 16384 1 - Live 0x0000000000000000
nf_reject_ipv6 16384 1 ip6t_REJECT, Live 0x0000000000000000
nf_log_ipv6 16384 6 - Live 0x0000000000000000
xt_hl 16384 22 - Live 0x0000000000000000
nf_conntrack_ipv6 20480 10 - Live 0x0000000000000000
nf_defrag_ipv6 36864 1 nf_conntrack_ipv6, Live 0x0000000000000000
ip6t_rt 16384 3 - Live 0x0000000000000000
ipt_REJECT 16384 1 - Live 0x0000000000000000
nf_reject_ipv4 16384 1 ipt_REJECT, Live 0x0000000000000000
nf_log_ipv4 16384 6 - Live 0x0000000000000000
nf_log_common 16384 2 nf_log_ipv6,nf_log_ipv4, Live 0x0000000000000000
xt_LOG 16384 12 - Live 0x0000000000000000
xt_recent 20480 8 - Live 0x0000000000000000
xt_multiport 16384 4 - Live 0x0000000000000000
xt_limit 16384 15 - Live 0x0000000000000000
xt_tcpudp 16384 51 - Live 0x0000000000000000
nf_conntrack_ipv4 16384 10 - Live 0x0000000000000000
nf_defrag_ipv4 16384 1 nf_conntrack_ipv4, Live 0x0000000000000000
xt_addrtype 16384 4 - Live 0x0000000000000000
xt_conntrack 16384 20 - Live 0x0000000000000000
ip6table_filter 16384 1 - Live 0x0000000000000000
ip6_tables 28672 1 ip6table_filter, Live 0x0000000000000000
nf_conntrack_netbios_ns 16384 0 - Live 0x0000000000000000
nf_conntrack_broadcast 16384 1 nf_conntrack_netbios_ns, Live 
0x0000000000000000
nf_nat_ftp 16384 0 - Live 0x0000000000000000
nf_nat 28672 1 nf_nat_ftp, Live 0x0000000000000000
nf_conntrack_ftp 20480 1 nf_nat_ftp, Live 0x0000000000000000
nf_conntrack 114688 8 
nf_conntrack_ipv6,nf_conntrack_ipv4,xt_conntrack,nf_conntrack_netbios_ns,nf_conntrack_broadcast,nf_nat_ftp,nf_nat,nf_conntrack_ftp, 
Live 0x0000000000000000
iptable_filter 16384 1 - Live 0x0000000000000000
ip_tables 28672 1 iptable_filter, Live 0x0000000000000000
x_tables 36864 15 
ip6t_REJECT,xt_hl,ip6t_rt,ipt_REJECT,xt_LOG,xt_recent,xt_multiport,xt_limit,xt_tcpudp,xt_addrtype,xt_conntrack,ip6table_filter,ip6_tables,iptable_filter,ip_tables, 
Live 0x0000000000000000
parport_pc 32768 0 - Live 0x0000000000000000
ppdev 20480 0 - Live 0x0000000000000000
lp 20480 0 - Live 0x0000000000000000
parport 49152 3 parport_pc,ppdev,lp, Live 0x0000000000000000
autofs4 40960 2 - Live 0x0000000000000000
hid_generic 16384 0 - Live 0x0000000000000000
usbhid 53248 0 - Live 0x0000000000000000
hid 122880 2 hid_generic,usbhid, Live 0x0000000000000000
amdgpu 1335296 0 - Live 0x0000000000000000
amdkfd 139264 2 - Live 0x0000000000000000
amd_iommu_v2 20480 1 amdkfd, Live 0x0000000000000000
radeon 1503232 0 - Live 0x0000000000000000
i2c_algo_bit 16384 2 amdgpu,radeon, Live 0x0000000000000000
ttm 102400 2 amdgpu,radeon, Live 0x0000000000000000
drm_kms_helper 159744 2 amdgpu,radeon, Live 0x0000000000000000
psmouse 139264 0 - Live 0x0000000000000000
syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
e1000e 249856 0 - Live 0x0000000000000000
fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
firewire_ohci 40960 0 - Live 0x0000000000000000
pata_acpi 16384 0 - Live 0x0000000000000000
drm 364544 4 amdgpu,radeon,ttm,drm_kms_helper, Live 0x0000000000000000
firewire_core 65536 1 firewire_ohci, Live 0x0000000000000000
ptp 20480 1 e1000e, Live 0x0000000000000000
crc_itu_t 16384 1 firewire_core, Live 0x0000000000000000
pps_core 20480 1 ptp, Live 0x0000000000000000
fjes 28672 0 - Live 0x0000000000000000
uas 24576 0 - Live 0x0000000000000000
usb_storage 73728 1 uas, Live 0x0000000000000000

[7.4] Loaded driver and hardware information

cat /proc/ioports
0000-0000 : PCI Bus 0000:00
   0000-0000 : dma1
   0000-0000 : pic1
   0000-0000 : timer0
   0000-0000 : timer1
   0000-0000 : keyboard
   0000-0000 : PNP0800:00
   0000-0000 : keyboard
   0000-0000 : rtc0
   0000-0000 : dma page reg
   0000-0000 : pic2
   0000-0000 : dma2
   0000-0000 : PNP0C04:00
     0000-0000 : fpu
   0000-0000 : vesafb
   0000-0000 : 0000:00:1f.3
   0000-0000 : pnp 00:03
   0000-0000 : gpio_ich.1.auto
     0000-0000 : 0000:00:1f.0
       0000-0000 : gpio_ich
       0000-0000 : gpio_ich
   0000-0000 : 0000:00:1f.0
     0000-0000 : pnp 00:03
       0000-0000 : ACPI PM1a_EVT_BLK
       0000-0000 : ACPI PM1a_CNT_BLK
       0000-0000 : ACPI PM_TMR
       0000-0000 : ACPI GPE0_BLK
       0000-0000 : iTCO_wdt.0.auto
       0000-0000 : ACPI PM2_CNT_BLK
       0000-0000 : iTCO_wdt.0.auto
   0000-0000 : pnp 00:02
   0000-0000 : pnp 00:02
   0000-0000 : pnp 00:02
   0000-0000 : pnp 00:02
0000-0000 : PCI conf1
0000-0000 : PCI Bus 0000:00
   0000-0000 : PCI Bus 0000:03
   0000-0000 : 0000:00:19.0
   0000-0000 : 0000:00:1a.0
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1a.1
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1a.2
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1d.0
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1d.1
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1d.2
     0000-0000 : uhci_hcd
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.2
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : 0000:00:1f.5
     0000-0000 : ata_piix
   0000-0000 : PCI Bus 0000:02
     0000-0000 : 0000:02:00.0
   0000-0000 : PCI Bus 0000:04
     0000-0000 : 0000:04:00.0

cat /proc/iomem
00000000-00000000 : reserved
00000000-00000000 : System RAM
00000000-00000000 : reserved
00000000-00000000 : PCI Bus 0000:00
00000000-00000000 : Video ROM
00000000-00000000 : PCI Bus 0000:00
00000000-00000000 : reserved
   00000000-00000000 : System ROM
00000000-00000000 : System RAM
   00000000-00000000 : Kernel code
   00000000-00000000 : Kernel data
   00000000-00000000 : Kernel bss
00000000-00000000 : ACPI Tables
00000000-00000000 : ACPI Non-volatile Storage
00000000-00000000 : reserved
00000000-00000000 : RAM buffer
00000000-00000000 : reserved
00000000-00000000 : PCI Bus 0000:00
   00000000-00000000 : PCI Bus 0000:03
   00000000-00000000 : PCI Bus 0000:03
   00000000-00000000 : PCI Bus 0000:02
   00000000-00000000 : PCI Bus 0000:04
     00000000-00000000 : 0000:04:00.0
00000000-00000000 : PCI MMCONFIG 0000 [bus 00-ff]
   00000000-00000000 : pnp 00:06
00000000-00000000 : PCI Bus 0000:00
   00000000-00000000 : 0000:00:19.0
     00000000-00000000 : e1000e
   00000000-00000000 : 0000:00:19.0
     00000000-00000000 : e1000e
   00000000-00000000 : 0000:00:1a.7
     00000000-00000000 : ehci_hcd
   00000000-00000000 : 0000:00:1b.0
     00000000-00000000 : ICH HD audio
   00000000-00000000 : 0000:00:1d.7
     00000000-00000000 : ehci_hcd
   00000000-00000000 : 0000:00:1f.3
   00000000-00000000 : PCI Bus 0000:02
     00000000-00000000 : 0000:02:00.0
       00000000-00000000 : firewire_ohci
   00000000-00000000 : PCI Bus 0000:04
     00000000-00000000 : 0000:04:00.0
     00000000-00000000 : 0000:04:00.1
       00000000-00000000 : ICH HD audio
   00000000-00000000 : pnp 00:00
   00000000-00000000 : pnp 00:00
   00000000-00000000 : pnp 00:00
   00000000-00000000 : pnp 00:00
   00000000-00000000 : IOAPIC 0
   00000000-00000000 : pnp 00:00
   00000000-00000000 : HPET 0
     00000000-00000000 : PNP0103:00
   00000000-00000000 : pnp 00:00
   00000000-00000000 : pnp 00:03
     00000000-00000000 : iTCO_wdt.0.auto
   00000000-00000000 : pnp 00:03
   00000000-00000000 : pnp 00:03
00000000-00000000 : Local APIC
   00000000-00000000 : reserved
     00000000-00000000 : pnp 00:05
00000000-00000000 : reserved
   00000000-00000000 : INT0800:00
   00000000-00000000 : pnp 00:04
   00000000-00000000 : INT0800:00
00000000-00000000 : System RAM

[7.5] PCI information

sudo lspci -vvv
00:00.0 Host bridge: Intel Corporation 5520/5500/X58 I/O Hub to ESI Port 
(rev 12)
     Subsystem: Intel Corporation 5520/5500/X58 I/O Hub to ESI Port
     Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR- INTx-
     Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
         Address: 00000000  Data: 0000
         Masking: 00000000  Pending: 00000000
     Capabilities: [90] Express (v2) Root Port (Slot-), MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag+ RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Exit 
Latency L0s <512ns, L1 <64us
             ClockPM- Surprise+ LLActRep+ BwNot+ ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ 
DLActive+ BWMgmt- ABWMgmt-
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible-
         RootCap: CRSVisible-
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         DevCap2: Completion Timeout: Range BCD, TimeoutDis+, LTR-, OBFF 
Not Supported ARIFwd+
         DevCtl2: Completion Timeout: 260ms to 900ms, TimeoutDis-, LTR-, 
OBFF Disabled ARIFwd-
         LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
              Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
              Compliance De-emphasis: -6dB
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [e0] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
     Capabilities: [150 v1] Access Control Services
         ACSCap:    SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ 
UpstreamFwd+ EgressCtrl- DirectTrans-
         ACSCtl:    SrcValid- TransBlk- ReqRedir- CmpltRedir- 
UpstreamFwd- EgressCtrl- DirectTrans-
     Capabilities: [160 v0] Vendor Specific Information: ID=0002 Rev=0 
Len=00c <?>

00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 1 (rev 12) (prog-if 00 [Normal decode])
     Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
     I/O behind bridge: 0000f000-00000fff
     Memory behind bridge: fff00000-000fffff
     Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [40] Subsystem: Intel Corporation 5520/5500/X58 I/O 
Hub PCI Express Root Port 1
     Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
         Address: 00000000  Data: 0000
         Masking: 00000000  Pending: 00000000
     Capabilities: [90] Express (v2) Root Port (Slot+), MSI 00
         DevCap:    MaxPayload 256 bytes, PhantFunc 0
             ExtTag+ RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 5GT/s, Width x4, ASPM L0s L1, Exit 
Latency L0s <512ns, L1 <64us
             ClockPM- Surprise+ LLActRep+ BwNot+ ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- 
Surprise-
             Slot #49, PowerLimit 25.000W; Interlock- NoCompl-
         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
             Control: AttnInd Off, PwrInd Off, Power- Interlock-
         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
Interlock-
             Changed: MRL- PresDet+ LinkState-
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible+
         RootCap: CRSVisible+
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         DevCap2: Completion Timeout: Range BCD, TimeoutDis+, LTR-, OBFF 
Not Supported ARIFwd+
         DevCtl2: Completion Timeout: 260ms to 900ms, TimeoutDis-, LTR-, 
OBFF Disabled ARIFwd-
         LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-
              Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
              Compliance De-emphasis: -6dB
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [e0] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
     Capabilities: [150 v1] Access Control Services
         ACSCap:    SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ 
UpstreamFwd+ EgressCtrl- DirectTrans-
         ACSCtl:    SrcValid- TransBlk- ReqRedir- CmpltRedir- 
UpstreamFwd- EgressCtrl- DirectTrans-
     Capabilities: [160 v0] Vendor Specific Information: ID=0002 Rev=0 
Len=00c <?>
     Kernel driver in use: pcieport
     Kernel modules: shpchp

00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 3 (rev 12) (prog-if 00 [Normal decode])
     Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
     I/O behind bridge: 0000f000-00000fff
     Memory behind bridge: fff00000-000fffff
     Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [40] Subsystem: Intel Corporation 5520/5500/X58 I/O 
Hub PCI Express Root Port 3
     Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
         Address: 00000000  Data: 0000
         Masking: 00000000  Pending: 00000000
     Capabilities: [90] Express (v2) Root Port (Slot+), MSI 00
         DevCap:    MaxPayload 256 bytes, PhantFunc 0
             ExtTag+ RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Exit 
Latency L0s <512ns, L1 <64us
             ClockPM- Surprise+ LLActRep+ BwNot+ ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- 
Surprise-
             Slot #51, PowerLimit 25.000W; Interlock- NoCompl-
         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
             Control: AttnInd Off, PwrInd Off, Power- Interlock-
         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
Interlock-
             Changed: MRL- PresDet+ LinkState-
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible+
         RootCap: CRSVisible+
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         DevCap2: Completion Timeout: Range BCD, TimeoutDis+, LTR-, OBFF 
Not Supported ARIFwd+
         DevCtl2: Completion Timeout: 260ms to 900ms, TimeoutDis-, LTR-, 
OBFF Disabled ARIFwd-
         LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-
              Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
              Compliance De-emphasis: -6dB
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [e0] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
     Capabilities: [150 v1] Access Control Services
         ACSCap:    SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ 
UpstreamFwd+ EgressCtrl- DirectTrans-
         ACSCtl:    SrcValid- TransBlk- ReqRedir- CmpltRedir- 
UpstreamFwd- EgressCtrl- DirectTrans-
     Capabilities: [160 v0] Vendor Specific Information: ID=0002 Rev=0 
Len=00c <?>
     Kernel driver in use: pcieport
     Kernel modules: shpchp

00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express 
Root Port 7 (rev 12) (prog-if 00 [Normal decode])
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
     I/O behind bridge: 0000e000-0000efff
     Memory behind bridge: fbe00000-fbefffff
     Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [40] Subsystem: Intel Corporation 5520/5500/X58 I/O 
Hub PCI Express Root Port 7
     Capabilities: [60] MSI: Enable- Count=1/2 Maskable+ 64bit-
         Address: 00000000  Data: 0000
         Masking: 00000000  Pending: 00000000
     Capabilities: [90] Express (v2) Root Port (Slot+), MSI 00
         DevCap:    MaxPayload 256 bytes, PhantFunc 0
             ExtTag+ RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 5GT/s, Width x16, ASPM L0s L1, Exit 
Latency L0s <512ns, L1 <64us
             ClockPM- Surprise+ LLActRep+ BwNot+ ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 5GT/s, Width x16, TrErr- Train- SlotClk+ 
DLActive+ BWMgmt+ ABWMgmt-
         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- 
Surprise-
             Slot #55, PowerLimit 75.000W; Interlock- NoCompl-
         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
             Control: AttnInd Off, PwrInd Off, Power- Interlock-
         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ 
Interlock-
             Changed: MRL- PresDet+ LinkState+
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible+
         RootCap: CRSVisible+
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         DevCap2: Completion Timeout: Range BCD, TimeoutDis+, LTR-, OBFF 
Not Supported ARIFwd+
         DevCtl2: Completion Timeout: 260ms to 900ms, TimeoutDis-, LTR-, 
OBFF Disabled ARIFwd-
         LnkCtl2: Target Link Speed: 5GT/s, EnterCompliance- SpeedDis-
              Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
              Compliance De-emphasis: -6dB
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [e0] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
     Capabilities: [150 v1] Access Control Services
         ACSCap:    SrcValid+ TransBlk+ ReqRedir+ CmpltRedir+ 
UpstreamFwd+ EgressCtrl- DirectTrans-
         ACSCtl:    SrcValid- TransBlk- ReqRedir- CmpltRedir- 
UpstreamFwd- EgressCtrl- DirectTrans-
     Capabilities: [160 v0] Vendor Specific Information: ID=0002 Rev=0 
Len=00c <?>
     Kernel driver in use: pcieport
     Kernel modules: shpchp

00:14.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub System 
Management Registers (rev 12) (prog-if 00 [8259])
     Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Capabilities: [40] Express (v2) Root Complex Integrated Endpoint, 
MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, 
OBFF Not Supported
         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
OBFF Disabled
     Kernel driver in use: i7core_edac
     Kernel modules: i7core_edac

00:14.1 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub GPIO and 
Scratch Pad Registers (rev 12) (prog-if 00 [8259])
     Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Capabilities: [40] Express (v2) Root Complex Integrated Endpoint, 
MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, 
OBFF Not Supported
         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
OBFF Disabled

00:14.2 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Control Status 
and RAS Registers (rev 12) (prog-if 00 [8259])
     Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Capabilities: [40] Express (v2) Root Complex Integrated Endpoint, 
MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
TransPend-
         DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, 
OBFF Not Supported
         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
OBFF Disabled

00:14.3 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Throttle 
Registers (rev 12) (prog-if 00 [8259])
     Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Kernel modules: i5500_temp

00:19.0 Ethernet controller: Intel Corporation 82567LF-2 Gigabit Network 
Connection
     Subsystem: Dell 82567LF-2 Gigabit Network Connection
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx+
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin A routed to IRQ 26
     Region 0: Memory at fbcc0000 (32-bit, non-prefetchable) [size=128K]
     Region 1: Memory at fbcf4000 (32-bit, non-prefetchable) [size=4K]
     Region 2: I/O ports at a080 [size=32]
     Capabilities: [c8] Power Management version 2
         Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
     Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Address: 00000000fee8000c  Data: 4123
     Capabilities: [e0] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: e1000e
     Kernel modules: e1000e

00:1a.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #4 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin A routed to IRQ 16
     Region 4: I/O ports at a400 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1a.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #5 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin B routed to IRQ 21
     Region 4: I/O ports at a480 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1a.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #6 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin D routed to IRQ 19
     Region 4: I/O ports at a800 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1a.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 
EHCI Controller #2 (prog-if 20 [EHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB2 EHCI Controller
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin C routed to IRQ 18
     Region 0: Memory at fbcf6000 (32-bit, non-prefetchable) [size=1K]
     Capabilities: [50] Power Management version 2
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [58] Debug port: BAR=1 offset=00a0
     Capabilities: [98] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: ehci-pci

00:1b.0 Audio device: Intel Corporation 82801JI (ICH10 Family) HD Audio 
Controller
     Subsystem: Dell 82801JI (ICH10 Family) HD Audio Controller
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx+
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Interrupt: pin A routed to IRQ 27
     Region 0: Memory at fbcf8000 (64-bit, non-prefetchable) [size=16K]
     Capabilities: [50] Power Management version 2
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Address: 00000000feefe00c  Data: 41c2
     Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, 
MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE-
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
TransPend-
     Capabilities: [100 v1] Virtual Channel
         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
         Arb:    Fixed- WRR32- WRR64- WRR128-
         Ctrl:    ArbSelect=Fixed
         Status:    InProgress-
         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
             Status:    NegoPending- InProgress-
         VC1:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
             Ctrl:    Enable- ID=0 ArbSelect=Fixed TC/VC=00
             Status:    NegoPending- InProgress-
     Capabilities: [130 v1] Root Complex Link
         Desc:    PortNumber=0f ComponentID=00 EltType=Config
         Link0:    Desc:    TargetPort=00 TargetComponent=00 AssocRCRB- 
LinkType=MemMapped LinkValid+
             Addr:    00000000fed1c000
     Kernel driver in use: snd_hda_intel
     Kernel modules: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express 
Root Port 1 (prog-if 00 [Normal decode])
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx+
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Interrupt: pin A routed to IRQ 24
     Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
     I/O behind bridge: 00001000-00001fff
     Memory behind bridge: c0000000-c01fffff
     Prefetchable memory behind bridge: 00000000c0200000-00000000c03fffff
     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
TransPend-
         LnkCap:    Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
Latency L0s <256ns, L1 <4us
             ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
         LnkCtl:    ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
Surprise+
             Slot #0, PowerLimit 10.000W; Interlock- NoCompl-
         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
             Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
Interlock-
             Changed: MRL- PresDet- LinkState-
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible-
         RootCap: CRSVisible-
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
         Address: feeff00c  Data: 41d1
     Capabilities: [90] Subsystem: Dell 82801JI (ICH10 Family) PCI 
Express Root Port 1
     Capabilities: [a0] Power Management version 2
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Virtual Channel
         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
         Arb:    Fixed+ WRR32- WRR64- WRR128-
         Ctrl:    ArbSelect=Fixed
         Status:    InProgress-
         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
             Status:    NegoPending- InProgress-
     Capabilities: [180 v1] Root Complex Link
         Desc:    PortNumber=01 ComponentID=00 EltType=Config
         Link0:    Desc:    TargetPort=00 TargetComponent=00 AssocRCRB- 
LinkType=MemMapped LinkValid+
             Addr:    00000000fed1c000
     Kernel driver in use: pcieport
     Kernel modules: shpchp

00:1c.1 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express 
Port 2 (prog-if 00 [Normal decode])
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx+
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Interrupt: pin B routed to IRQ 25
     Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
     I/O behind bridge: 0000d000-0000dfff
     Memory behind bridge: fbd00000-fbdfffff
     Prefetchable memory behind bridge: 00000000c0400000-00000000c05fffff
     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0
             ExtTag- RBE+
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 128 bytes
         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
TransPend-
         LnkCap:    Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
Latency L0s <1us, L1 <4us
             ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
DLActive+ BWMgmt- ABWMgmt-
         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
Surprise+
             Slot #0, PowerLimit 10.000W; Interlock- NoCompl-
         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- 
HPIrq- LinkChg-
             Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ 
Interlock-
             Changed: MRL- PresDet+ LinkState+
         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- 
CRSVisible-
         RootCap: CRSVisible-
         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
         Address: feeff00c  Data: 4122
     Capabilities: [90] Subsystem: Dell 82801JI (ICH10 Family) PCI 
Express Port 2
     Capabilities: [a0] Power Management version 2
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [100 v1] Virtual Channel
         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
         Arb:    Fixed+ WRR32- WRR64- WRR128-
         Ctrl:    ArbSelect=Fixed
         Status:    InProgress-
         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
             Status:    NegoPending- InProgress-
     Capabilities: [180 v1] Root Complex Link
         Desc:    PortNumber=02 ComponentID=00 EltType=Config
         Link0:    Desc:    TargetPort=00 TargetComponent=00 AssocRCRB- 
LinkType=MemMapped LinkValid+
             Addr:    00000000fed1c000
     Kernel driver in use: pcieport
     Kernel modules: shpchp

00:1d.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #1 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin A routed to IRQ 23
     Region 4: I/O ports at a880 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1d.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #2 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin B routed to IRQ 19
     Region 4: I/O ports at ac00 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1d.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB 
UHCI Controller #3 (prog-if 00 [UHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB UHCI Controller
     Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin C routed to IRQ 18
     Region 4: I/O ports at b000 [size=32]
     Capabilities: [50] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: uhci_hcd

00:1d.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 
EHCI Controller #1 (prog-if 20 [EHCI])
     Subsystem: Dell 82801JI (ICH10 Family) USB2 EHCI Controller
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin A routed to IRQ 23
     Region 0: Memory at fbcfc000 (32-bit, non-prefetchable) [size=1K]
     Capabilities: [50] Power Management version 2
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [58] Debug port: BAR=1 offset=00a0
     Capabilities: [98] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: ehci-pci

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90) (prog-if 
01 [Subtractive decode])
     Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
     I/O behind bridge: 0000f000-00000fff
     Memory behind bridge: fff00000-000fffff
     Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
     Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
     Capabilities: [50] Subsystem: Dell 82801 PCI Bridge

00:1f.0 ISA bridge: Intel Corporation 82801JIR (ICH10R) LPC Interface 
Controller
     Subsystem: Dell 82801JIR (ICH10R) LPC Interface Controller
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Capabilities: [e0] Vendor Specific Information: Len=0c <?>
     Kernel driver in use: lpc_ich
     Kernel modules: lpc_ich

00:1f.2 IDE interface: Intel Corporation 82801JI (ICH10 Family) 4 port 
SATA IDE Controller #1 (prog-if 8f [Master SecP SecO PriP PriO])
     Subsystem: Dell 82801JI (ICH10 Family) 4 port SATA IDE Controller
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin B routed to IRQ 19
     Region 0: I/O ports at bc00 [size=8]
     Region 1: I/O ports at b880 [size=4]
     Region 2: I/O ports at b800 [size=8]
     Region 3: I/O ports at b480 [size=4]
     Region 4: I/O ports at b400 [size=16]
     Region 5: I/O ports at b080 [size=16]
     Capabilities: [70] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [b0] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: ata_piix
     Kernel modules: pata_acpi

00:1f.3 SMBus: Intel Corporation 82801JI (ICH10 Family) SMBus Controller
     Subsystem: Dell 82801JI (ICH10 Family) SMBus Controller
     Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Interrupt: pin C routed to IRQ 15
     Region 0: Memory at fbcffc00 (64-bit, non-prefetchable) [size=256]
     Region 4: I/O ports at 0400 [size=32]
     Kernel modules: i2c_i801

00:1f.5 IDE interface: Intel Corporation 82801JI (ICH10 Family) 2 port 
SATA IDE Controller #2 (prog-if 85 [Master SecO PriO])
     Subsystem: Dell 82801JI (ICH10 Family) 2 port SATA IDE Controller
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0
     Interrupt: pin B routed to IRQ 19
     Region 0: I/O ports at cc00 [size=8]
     Region 1: I/O ports at c880 [size=4]
     Region 2: I/O ports at c800 [size=8]
     Region 3: I/O ports at c480 [size=4]
     Region 4: I/O ports at c400 [size=16]
     Region 5: I/O ports at c080 [size=16]
     Capabilities: [70] Power Management version 3
         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [b0] PCI Advanced Features
         AFCap: TP+ FLR+
         AFCtrl: FLR-
         AFStatus: TP-
     Kernel driver in use: ata_piix
     Kernel modules: pata_acpi

02:00.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6315 Series 
Firewire Controller (prog-if 10 [OHCI])
     Subsystem: Dell VT6315 Series Firewire Controller
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Interrupt: pin A routed to IRQ 17
     Region 0: Memory at fbdff800 (64-bit, non-prefetchable) [size=2K]
     Region 2: I/O ports at d800 [size=256]
     Capabilities: [50] Power Management version 3
         Flags: PMEClk- DSI- D1- D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2+,D3hot+,D3cold+)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [80] MSI: Enable- Count=1/1 Maskable+ 64bit+
         Address: 0000000000000000  Data: 0000
         Masking: 00000000  Pending: 00000000
     Capabilities: [98] Express (v1) Endpoint, MSI 00
         DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
<64ns, L1 <1us
             ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
             MaxPayload 128 bytes, MaxReadReq 512 bytes
         DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ 
TransPend-
         LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
Latency L0s <1us, L1 <64us
             ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp-
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk- 
DLActive- BWMgmt- ABWMgmt-
     Capabilities: [100 v1] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
     Capabilities: [130 v1] Device Serial Number 90-21-a0-ff-ff-00-00-00
     Kernel driver in use: firewire_ohci
     Kernel modules: firewire_ohci

04:00.0 VGA compatible controller: Advanced Micro Devices, Inc. 
[AMD/ATI] Curacao PRO [Radeon R7 370 / R9 270/370 OEM] (rev 81) (prog-if 
00 [VGA controller])
     Subsystem: Micro-Star International Co., Ltd. [MSI] Curacao PRO 
[Radeon R7 370 / R9 270/370 OEM]
     Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Interrupt: pin A routed to IRQ 16
     Region 0: Memory at d0000000 (64-bit, prefetchable) [size=256M]
     Region 2: Memory at fbe80000 (64-bit, non-prefetchable) [size=256K]
     Region 4: I/O ports at e000 [size=256]
     Expansion ROM at 000c0000 [disabled] [size=128K]
     Capabilities: [48] Vendor Specific Information: Len=08 <?>
     Capabilities: [50] Power Management version 3
         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1+,D2+,D3hot+,D3cold-)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
         DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, 
L1 unlimited
             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
             MaxPayload 128 bytes, MaxReadReq 512 bytes
         DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 8GT/s, Width x16, ASPM L0s L1, Exit 
Latency L0s <64ns, L1 <1us
             ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp+
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 5GT/s, Width x16, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, 
OBFF Not Supported
         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
OBFF Disabled
         LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
              Transmit Margin: Normal Operating Range, 
EnterModifiedCompliance- ComplianceSOS-
              Compliance De-emphasis: -6dB
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
         Address: 0000000000000000  Data: 0000
     Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 
Len=010 <?>
     Capabilities: [150 v2] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
     Capabilities: [200 v1] #15
     Capabilities: [270 v1] #19
     Capabilities: [2b0 v1] Address Translation Service (ATS)
         ATSCap:    Invalidate Queue Depth: 00
         ATSCtl:    Enable-, Smallest Translation Unit: 00
     Capabilities: [2c0 v1] #13
     Capabilities: [2d0 v1] #1b
     Kernel modules: radeon, amdgpu

04:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Cape 
Verde/Pitcairn HDMI Audio [Radeon HD 7700/7800 Series]
     Subsystem: Micro-Star International Co., Ltd. [MSI] Cape 
Verde/Pitcairn HDMI Audio [Radeon HD 7700/7800 Series]
     Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx+
     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0, Cache Line Size: 64 bytes
     Interrupt: pin B routed to IRQ 28
     Region 0: Memory at fbefc000 (64-bit, non-prefetchable) [size=16K]
     Capabilities: [48] Vendor Specific Information: Len=08 <?>
     Capabilities: [50] Power Management version 3
         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
     Capabilities: [58] Express (v2) Legacy Endpoint, MSI 00
         DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <4us, 
L1 unlimited
             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
Unsupported-
             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
             MaxPayload 128 bytes, MaxReadReq 512 bytes
         DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- 
TransPend-
         LnkCap:    Port #0, Speed 8GT/s, Width x16, ASPM L0s L1, Exit 
Latency L0s <64ns, L1 <1us
             ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp+
         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk+
             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
         LnkSta:    Speed 5GT/s, Width x16, TrErr- Train- SlotClk+ 
DLActive- BWMgmt- ABWMgmt-
         DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, 
OBFF Not Supported
         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
OBFF Disabled
         LnkSta2: Current De-emphasis Level: -6dB, 
EqualizationComplete-, EqualizationPhase1-
              EqualizationPhase2-, EqualizationPhase3-, 
LinkEqualizationRequest-
     Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
         Address: 00000000feefe00c  Data: 41d2
     Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 
Len=010 <?>
     Capabilities: [150 v2] Advanced Error Reporting
         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
         UESvrt:    DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
         CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
         AERCap:    First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
     Kernel driver in use: snd_hda_intel
     Kernel modules: snd_hda_intel

ff:00.0 Host bridge: Intel Corporation Xeon 5500/Core i7 QuickPath 
Architecture Generic Non-Core Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 QuickPath 
Architecture Generic Non-Core Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:00.1 Host bridge: Intel Corporation Xeon 5500/Core i7 QuickPath 
Architecture System Address Decoder (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 QuickPath 
Architecture System Address Decoder
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:02.0 Host bridge: Intel Corporation Xeon 5500/Core i7 QPI Link 0 (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 QPI Link 0
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:02.1 Host bridge: Intel Corporation Xeon 5500/Core i7 QPI Physical 0 
(rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 QPI Physical 0
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:03.0 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:03.1 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Target Address Decoder (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Target Address Decoder
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:03.4 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Test Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Test Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:04.0 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 0 Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 0 Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:04.1 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 0 Address Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 0 Address Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:04.2 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 0 Rank Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 0 Rank Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:04.3 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 0 Thermal Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 0 Thermal Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:05.0 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 1 Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 1 Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:05.1 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 1 Address Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 1 Address Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:05.2 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 1 Rank Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 1 Rank Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:05.3 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 1 Thermal Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 1 Thermal Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:06.0 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 2 Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 2 Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:06.1 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 2 Address Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 2 Address Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:06.2 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 2 Rank Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 2 Rank Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

ff:06.3 Host bridge: Intel Corporation Xeon 5500/Core i7 Integrated 
Memory Controller Channel 2 Thermal Control Registers (rev 04)
     Subsystem: Intel Corporation Xeon 5500/Core i7 Integrated Memory 
Controller Channel 2 Thermal Control Registers
     Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B- DisINTx-
     Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR- INTx-
     Latency: 0

[7.6] SCSI information

cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST31000340AS     Rev: DE13
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
   Vendor: HL-DT-ST Model: BD-RE  BH20N     Rev: B103
   Type:   CD-ROM                           ANSI  SCSI revision: 05
Host: scsi4 Channel: 00 Id: 00 Lun: 00
   Vendor: DELL     Model: USB   HS-CF Card Rev: 7.08
   Type:   Direct-Access                    ANSI  SCSI revision: 00
Host: scsi4 Channel: 00 Id: 00 Lun: 01
   Vendor: DELL     Model: USB   HS-xD/SM   Rev: 7.08
   Type:   Direct-Access                    ANSI  SCSI revision: 00
Host: scsi4 Channel: 00 Id: 00 Lun: 02
   Vendor: DELL     Model: USB   HS-MS Card Rev: 7.08
   Type:   Direct-Access                    ANSI  SCSI revision: 00
Host: scsi4 Channel: 00 Id: 00 Lun: 03
   Vendor: DELL     Model: USB   HS-SD Card Rev: 7.08
   Type:   Direct-Access                    ANSI  SCSI revision: 00

[7.7] Other information

ls /proc
1     124  14    155   189   2019  2117  2259  24 260   297   3465  48   
64   76   913        dma kpagecount    slabinfo
10    125  140   156   19    2026  2120  2272  2402 261   2977  3499  
49   65   77   916        driver kpageflags    softirqs
1029  126  141   1589  190   2035  2126  2278  2412 2619  3     3556  
5    66   777  918        execdomains loadavg       stat
1033  127  142   16    1919  2049  214   2286  2415 262   30    357   
50   67   78   924        fb locks         swaps
1034  128  143   1610  1929  2051  215   2290  2443 2632  3000  3582  
51   68   783  925        filesystems mdstat        sys
11    129  144   162   1941  2056  2157  2291  2460 268   302   36    
52   69   8    928        fs meminfo       sysrq-trigger
1107  13   145   163   1966  2058  216   2314  2470 27    303   37    
54   7    81   acpi       i8k misc          sysvipc
1127  130  146   1700  1968  2065  2171  2317  2474 2708  3089  38    
546  70   82   asound     interrupts modules       thread-self
1144  131  147   1723  1972  2067  22    233   2478 28    31    381   
55   71   83   buddyinfo  iomem mounts        timer_list
1145  132  148   1791  1977  2082  2205  2332  2493 285   32    39    
56   72   858  bus        ioports mtrr          timer_stats
1152  133  149   18    1997  21    2231  2337  25 286   3250  40    57   
73   864  cgroups    irq net           tty
1161  134  1492  1817  2     2106  2232  2340  2531 2874  33    42    
58   74   866  cmdline    kallsyms pagetypeinfo  uptime
1196  135  15    1818  20    2107  2233  2367  2551 290   3327  43    
59   75   868  consoles   kcore partitions    version
12    136  150   1823  2002  2109  2234  237   2555 293   333   44    
60   756  9    cpuinfo    keys sched_debug   vmallocinfo
1216  137  151   1825  2011  2111  2236  2382  2557 294   3334  45    
61   757  906  crypto     key-users schedstat     vmstat
122   138  153   185   2012  2113  2237  2383  2564 295   336   452   
62   758  907  devices    kmsg scsi          zoneinfo
123   139  154   188   2014  2115  2251  2393  26 296   34    46    63   
759  911  diskstats  kpagecgroup  self

[X.] Other notes

Full details of the Launchpad bug may found here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1613027


Regards. Thanks.

Tony
