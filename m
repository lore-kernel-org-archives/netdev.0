From: Tuomas Jormola <tj@solitudo.net>
Subject: PROBLEM: A set of networking related oopses
Date: Thu, 6 Mar 2008 21:05:02 +0200
Message-ID: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-6-1037319543
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh03.mail.saunalahti.fi ([62.142.5.109]:58498 "EHLO
	emh03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759003AbYCFTMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 14:12:18 -0500
Received: from saunalahti-vams (vs3-10.mail.saunalahti.fi [62.142.5.94])
	by emh03-2.mail.saunalahti.fi (Postfix) with SMTP id D4CF8EBF2D
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 21:05:05 +0200 (EET)
Received: from gauri.home.local.domain (a88-112-56-221.elisa-laajakaista.fi [88.112.56.221])
	by emh05.mail.saunalahti.fi (Postfix) with ESMTP id A1FA527DA3
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 21:05:02 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-6-1037319543
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

Hello,

[1.] One line summary of the problem:
My gateway machine is suffering from kernel oopses that don't kill the  
machine, but do occur every now and then

[2.] Full description of the problem/report:
I'm running a (NAT) gateway and file server for my home network. The  
machine is connected to the local network via 1Gbit ethernet on the  
motherboard (Intel IHC9 chipset, e1000e driver). Another interface is  
connected to ADSL box via 100Mbit Intel ethernet card (e100 driver).  
The root file system is on an LVM logical volume backed by a software  
raid5 device. There's quite complicated iptables setup managed with  
Shorewall. There's also two IPSEC tunnels setup with racoon. I can  
provide more details about the setup if required. The oopses occur  
every now and then, but I've not been able to detect the pattern when  
they occur or how to reproduce the problems (I'm not even sure if the  
attached oopses are related or are they distinct problems altogether).

[3.] Keywords (i.e., modules, networking, kernel):
networking, oops

[4.] Kernel version (from /proc/version):
This kernel is packaged by Ubuntu for the upcoming hardy release.
(20:51:12)(tj@shakti)(~)$ cat /proc/version
Linux version 2.6.24-8-server (buildd@rothera) (gcc version 4.2.3  
(Ubuntu 4.2.3-1ubuntu2)) #1 SMP Thu Feb 14 21:21:53 UTC 2008

[5.] Output of Oops.. message (if applicable) with symbolic information
      resolved (see Documentation/oops-tracing.txt)
See four attached files

[6.] A small shell script or example program which triggers the
      problem (if possible)
N/A. I have no idea have triggers the oops

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
(20:52:42)(tj@shakti)(~)$ /usr/src/linux-headers-2.6.24-8/scripts/ 
ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux shakti 2.6.24-8-server #1 SMP Thu Feb 14 21:21:53 UTC 2008 i686  
GNU/Linux

Gnu C                  4.1.3
Gnu make               3.81
binutils               2.18
util-linux             2.13
mount                  2.13
module-init-tools      3.3-pre11
e2fsprogs              1.40.2
jfsutils               1.1.11
reiserfsprogs          3.6.19
reiser4progs           1.0.6
xfsprogs               2.9.0
Linux C Library        2.7
Dynamic linker (ldd)   2.7
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   113
Modules Loaded         nls_cp437 isofs ztdummy zaptel crc_ccitt nfs  
esp4 xfrm4_mode_tunnel nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs  
ppdev parport_pc lp parport sch_sfq act_police cls_u32 sch_ingress  
sch_htb ip6table_filter iptable_raw xt_comment xt_policy xt_multiport  
ipt_ULOG ipt_TTL ipt_ttl ipt_TOS ipt_tos ipt_SAME ipt_REJECT  
ipt_REDIRECT ipt_recent ipt_owner ipt_NETMAP ipt_MASQUERADE ipt_LOG  
ipt_iprange ipt_ECN ipt_ecn ipt_CLUSTERIP ipt_ah ipt_addrtype  
nf_nat_tftp nf_nat_snmp_basic nf_nat_sip nf_nat_pptp nf_nat_proto_gre  
nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp  
nf_conntrack_amanda nf_conntrack_tftp nf_conntrack_sip  
nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre  
nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_irc  
nf_conntrack_h323 nf_conntrack_ftp xt_tcpmss xt_pkttype xt_physdev  
xt_NFQUEUE xt_NFLOG xt_MARK xt_mark xt_mac xt_limit xt_length  
xt_helper xt_hashlimit ip6_tables xt_dccp xt_conntrack xt_CONNMARK  
xt_connmark xt_CLASSIFY xt_tcpudp xt_state iptable_nat nf_nat  
nf_conntrack_ipv4 nf_conntrack iptable_mangle nfnetlink iptable_filter  
ip_tables x_tables deflate zlib_deflate twofish twofish_common  
camellia serpent blowfish des_generic cbc ecb aes_i586 aes_generic  
geode_aes blkcipher xcbc sha256_generic sha1_generic crypto_null  
af_key ext3 jbd mbcache coretemp ipv6 loop af_packet evdev psmouse  
pcspkr serio_raw iTCO_wdt iTCO_vendor_support shpchp pci_hotplug  
button intel_agp agpgart e1000e heci xfs pata_marvell sg sd_mod  
pata_acpi ohci1394 ahci ata_generic ehci_hcd e100 uhci_hcd ieee1394  
libata mii scsi_mod usbcore raid10 raid456 async_xor async_memcpy  
async_tx xor raid1 raid0 multipath linear md_mod dm_mirror dm_snapshot  
dm_mod thermal processor fan fuse
(20:52:43)(tj@shakti)(~)$

[7.2.] Processor information (from /proc/cpuinfo):
(20:52:43)(tj@shakti)(~)$ cat /proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 15
model name	: Intel(R) Core(TM)2 Duo CPU     E4500  @ 2.20GHz
stepping	: 13
cpu MHz		: 2200.142
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 2
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov  
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm  
constant_tsc arch_perfmon pebs bts pni monitor ds_cpl est tm2 ssse3  
cx16 xtpr lahf_lm
bogomips	: 4402.81
clflush size	: 64

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 15
model name	: Intel(R) Core(TM)2 Duo CPU     E4500  @ 2.20GHz
stepping	: 13
cpu MHz		: 2200.142
cache size	: 2048 KB
physical id	: 0
siblings	: 2
core id		: 1
cpu cores	: 2
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 10
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov  
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm  
constant_tsc arch_perfmon pebs bts pni monitor ds_cpl est tm2 ssse3  
cx16 xtpr lahf_lm
bogomips	: 4400.17
clflush size	: 64

(20:53:00)(tj@shakti)(~)$

[7.3.] Module information (from /proc/modules):
(20:53:00)(tj@shakti)(~)$ cat /proc/modules
nls_cp437 6656 0 - Live 0xf924f000
isofs 36260 0 - Live 0xf9330000
ztdummy 5584 0 - Live 0xf91ef000
zaptel 193412 1 ztdummy, Live 0xf9422000
crc_ccitt 3072 1 zaptel, Live 0xf91e9000
nfs 261900 0 - Live 0xf937e000
esp4 8704 8 - Live 0xf924b000
xfrm4_mode_tunnel 3840 16 - Live 0xf91dc000
nfsd 228464 13 - Live 0xf92f7000
lockd 67720 3 nfs,nfsd, Live 0xf92aa000
nfs_acl 4608 2 nfs,nfsd, Live 0xf9248000
auth_rpcgss 43424 1 nfsd, Live 0xf9255000
sunrpc 185756 12 nfs,nfsd,lockd,nfs_acl,auth_rpcgss, Live 0xf927b000
exportfs 6016 1 nfsd, Live 0xf91f2000
ppdev 10372 0 - Live 0xf91eb000
parport_pc 36644 0 - Live 0xf9202000
lp 12324 0 - Live 0xf91fd000
parport 37704 3 ppdev,parport_pc,lp, Live 0xf923d000
sch_sfq 7168 4 - Live 0xf91fa000
act_police 7876 1 - Live 0xf91aa000
cls_u32 8964 2 - Live 0xf91f6000
sch_ingress 4480 1 - Live 0xf91d6000
sch_htb 18944 1 - Live 0xf920d000
ip6table_filter 3584 1 - Live 0xf91d4000
iptable_raw 3328 0 - Live 0xf91d2000
xt_comment 2688 0 - Live 0xf91de000
xt_policy 4736 48 - Live 0xf91cf000
xt_multiport 4224 36 - Live 0xf91c7000
ipt_ULOG 10116 0 - Live 0xf91cb000
ipt_TTL 3200 0 - Live 0xf91c5000
ipt_ttl 2816 0 - Live 0xf91c3000
ipt_TOS 3200 0 - Live 0xf91c1000
ipt_tos 2560 0 - Live 0xf91bf000
ipt_SAME 3200 0 - Live 0xf91bd000
ipt_REJECT 5632 4 - Live 0xf91b6000
ipt_REDIRECT 2944 2 - Live 0xf91b4000
ipt_recent 10264 0 - Live 0xf91b9000
ipt_owner 2944 5 - Live 0xf91b2000
ipt_NETMAP 2944 0 - Live 0xf91b0000
ipt_MASQUERADE 4608 1 - Live 0xf91ad000
ipt_LOG 7296 10 - Live 0xf9196000
ipt_iprange 2688 0 - Live 0xf91a8000
ipt_ECN 3840 0 - Live 0xf91a1000
ipt_ecn 3200 0 - Live 0xf919f000
ipt_CLUSTERIP 9604 0 - Live 0xf91a4000
ipt_ah 2816 0 - Live 0xf919d000
ipt_addrtype 2816 0 - Live 0xf919b000
nf_nat_tftp 2816 0 - Live 0xf9199000
nf_nat_snmp_basic 11012 0 - Live 0xf915b000
nf_nat_sip 5760 0 - Live 0xf9193000
nf_nat_pptp 4608 0 - Live 0xf9190000
nf_nat_proto_gre 3716 1 nf_nat_pptp, Live 0xf918e000
nf_nat_irc 3712 0 - Live 0xf918c000
nf_nat_h323 8576 0 - Live 0xf9188000
nf_nat_ftp 4352 0 - Live 0xf9185000
nf_nat_amanda 3328 0 - Live 0xf9181000
ts_kmp 3072 5 - Live 0xf9183000
nf_conntrack_amanda 5888 1 nf_nat_amanda, Live 0xf917e000
nf_conntrack_tftp 6036 1 nf_nat_tftp, Live 0xf915f000
nf_conntrack_sip 10132 1 nf_nat_sip, Live 0xf917a000
nf_conntrack_proto_sctp 9864 0 - Live 0xf9154000
nf_conntrack_pptp 8064 1 nf_nat_pptp, Live 0xf9158000
nf_conntrack_proto_gre 7040 1 nf_conntrack_pptp, Live 0xf914b000
nf_conntrack_netlink 28800 0 - Live 0xf9171000
nf_conntrack_netbios_ns 3840 0 - Live 0xf914e000
nf_conntrack_irc 7576 1 nf_nat_irc, Live 0xf912c000
nf_conntrack_h323 51164 1 nf_nat_h323, Live 0xf9163000
nf_conntrack_ftp 10144 1 nf_nat_ftp, Live 0xf9150000
xt_tcpmss 3200 0 - Live 0xf9149000
xt_pkttype 2816 4 - Live 0xf9147000
xt_physdev 3600 0 - Live 0xf9145000
xt_NFQUEUE 2816 0 - Live 0xf9143000
xt_NFLOG 2944 0 - Live 0xf9141000
xt_MARK 3200 8 - Live 0xf913f000
xt_mark 2816 4 - Live 0xf913d000
xt_mac 2816 0 - Live 0xf913b000
xt_limit 3584 0 - Live 0xf9139000
xt_length 2816 0 - Live 0xf9137000
xt_helper 3584 0 - Live 0xf912f000
xt_hashlimit 11276 0 - Live 0xf8c8a000
ip6_tables 15844 2 ip6table_filter,xt_hashlimit, Live 0xf9132000
xt_dccp 4356 0 - Live 0xf9129000
xt_conntrack 3712 0 - Live 0xf9127000
xt_CONNMARK 4224 1 - Live 0xf9124000
xt_connmark 3200 1 - Live 0xf9122000
xt_CLASSIFY 2688 4 - Live 0xf910e000
xt_tcpudp 4096 58 - Live 0xf90ff000
xt_state 3328 45 - Live 0xf90e8000
iptable_nat 8324 1 - Live 0xf90fb000
nf_nat 20268 14  
ipt_SAME 
,ipt_REDIRECT 
,ipt_NETMAP 
,ipt_MASQUERADE 
,nf_nat_tftp 
,nf_nat_sip 
,nf_nat_pptp 
,nf_nat_proto_gre 
,nf_nat_irc 
,nf_nat_h323 
,nf_nat_ftp,nf_nat_amanda,nf_conntrack_netlink,iptable_nat, Live  
0xf9108000
nf_conntrack_ipv4 19080 49 iptable_nat, Live 0xf9102000
nf_conntrack 66624 29  
ipt_MASQUERADE 
,ipt_CLUSTERIP 
,nf_nat_tftp 
,nf_nat_snmp_basic 
,nf_nat_sip 
,nf_nat_pptp 
,nf_nat_irc 
,nf_nat_h323 
,nf_nat_ftp 
,nf_nat_amanda 
,nf_conntrack_amanda 
,nf_conntrack_tftp 
,nf_conntrack_sip 
,nf_conntrack_proto_sctp 
,nf_conntrack_pptp 
,nf_conntrack_proto_gre 
,nf_conntrack_netlink 
,nf_conntrack_netbios_ns 
,nf_conntrack_irc 
,nf_conntrack_h323 
,nf_conntrack_ftp 
,xt_helper 
,xt_conntrack 
,xt_CONNMARK 
,xt_connmark,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4, Live  
0xf9110000
iptable_mangle 3712 1 - Live 0xf90e6000
nfnetlink 5784 1 nf_conntrack_netlink, Live 0xf90e3000
iptable_filter 3840 1 - Live 0xf8cfe000
ip_tables 14820 4  
iptable_raw,iptable_nat,iptable_mangle,iptable_filter, Live 0xf90f6000
x_tables 16132 44  
xt_comment 
,xt_policy 
,xt_multiport 
,ipt_ULOG 
,ipt_TTL 
,ipt_ttl 
,ipt_TOS 
,ipt_tos 
,ipt_SAME 
,ipt_REJECT 
,ipt_REDIRECT 
,ipt_recent 
,ipt_owner 
,ipt_NETMAP 
,ipt_MASQUERADE 
,ipt_LOG 
,ipt_iprange 
,ipt_ECN 
,ipt_ecn 
,ipt_CLUSTERIP 
,ipt_ah 
,ipt_addrtype 
,xt_tcpmss 
,xt_pkttype 
,xt_physdev 
,xt_NFQUEUE 
,xt_NFLOG 
,xt_MARK 
,xt_mark 
,xt_mac 
,xt_limit 
,xt_length 
,xt_helper 
,xt_hashlimit 
,ip6_tables 
,xt_dccp 
,xt_conntrack 
,xt_CONNMARK 
,xt_connmark,xt_CLASSIFY,xt_tcpudp,xt_state,iptable_nat,ip_tables,  
Live 0xf90f1000
deflate 4736 0 - Live 0xf90c5000
zlib_deflate 20760 1 deflate, Live 0xf90ea000
twofish 7680 0 - Live 0xf90c2000
twofish_common 38528 1 twofish, Live 0xf90cf000
camellia 29568 0 - Live 0xf90da000
serpent 19456 0 - Live 0xf90c9000
blowfish 9216 0 - Live 0xf90be000
des_generic 17280 0 - Live 0xf909b000
cbc 5504 8 - Live 0xf9098000
ecb 4480 0 - Live 0xf9095000
aes_i586 33536 8 - Live 0xf90b4000
aes_generic 27712 0 - Live 0xf90ac000
geode_aes 7176 0 - Live 0xf8cfb000
blkcipher 8068 3 cbc,ecb,geode_aes, Live 0xf8c8e000
xcbc 6920 0 - Live 0xf8b1e000
sha256_generic 12160 0 - Live 0xf8cc2000
sha1_generic 3584 0 - Live 0xf8b3d000
crypto_null 3584 0 - Live 0xf8b21000
af_key 37520 2 - Live 0xf90a1000
ext3 136584 1 - Live 0xf8cc6000
jbd 48404 1 ext3, Live 0xf8c91000
mbcache 9600 1 ext3, Live 0xf8b72000
coretemp 8448 0 - Live 0xf8b6e000
ipv6 272804 65 nf_conntrack_h323, Live 0xf8d81000
loop 19076 0 - Live 0xf8b68000
af_packet 23684 4 - Live 0xf8b61000
evdev 12928 0 - Live 0xf8b23000
psmouse 40208 0 - Live 0xf8b2c000
pcspkr 4224 0 - Live 0xf8a6c000
serio_raw 7940 0 - Live 0xf896f000
iTCO_wdt 13092 0 - Live 0xf8b19000
iTCO_vendor_support 4868 1 iTCO_wdt, Live 0xf8a1f000
shpchp 34452 0 - Live 0xf8a55000
pci_hotplug 30880 1 shpchp, Live 0xf8a60000
button 9232 0 - Live 0xf8a28000
intel_agp 25620 1 - Live 0xf8a4d000
agpgart 34760 1 intel_agp, Live 0xf8a43000
e1000e 98212 0 - Live 0xf8b00000
heci 60192 0 - Live 0xf8a33000
xfs 570136 13 - Live 0xf8a73000
pata_marvell 7936 1 - Live 0xf8891000
sg 36496 0 - Live 0xf89c1000
sd_mod 30592 10 - Live 0xf89cc000
pata_acpi 8320 0 - Live 0xf896b000
ohci1394 33968 0 - Live 0xf89b7000
ahci 28420 4 - Live 0xf8955000
ata_generic 8324 0 - Live 0xf892a000
ehci_hcd 37516 0 - Live 0xf89ac000
e100 37516 0 - Live 0xf8974000
uhci_hcd 27152 0 - Live 0xf895f000
ieee1394 93752 1 ohci1394, Live 0xf88c8000
libata 159344 4 pata_marvell,pata_acpi,ahci,ata_generic, Live 0xf8984000
mii 6400 1 e100, Live 0xf88a3000
scsi_mod 151180 3 sg,sd_mod,libata, Live 0xf8904000
usbcore 145516 3 ehci_hcd,uhci_hcd, Live 0xf8930000
raid10 25856 0 - Live 0xf88c0000
raid456 129040 1 - Live 0xf88e3000
async_xor 4992 1 raid456, Live 0xf8894000
async_memcpy 3840 1 raid456, Live 0xf8844000
async_tx 9292 3 raid456,async_xor,async_memcpy, Live 0xf883c000
xor 16136 2 raid456,async_xor, Live 0xf8898000
raid1 25728 0 - Live 0xf8878000
raid0 9344 0 - Live 0xf8874000
multipath 9600 0 - Live 0xf8840000
linear 7296 0 - Live 0xf8836000
md_mod 82068 7 raid10,raid456,raid1,raid0,multipath,linear, Live  
0xf88aa000
dm_mirror 24704 0 - Live 0xf886c000
dm_snapshot 19620 0 - Live 0xf885a000
dm_mod 62532 30 dm_mirror,dm_snapshot, Live 0xf8880000
thermal 16796 0 - Live 0xf8854000
processor 37000 1 thermal, Live 0xf8861000
fan 5636 0 - Live 0xf8839000
fuse 50580 1 - Live 0xf8846000
(20:53:13)(tj@shakti)(~)$

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/ 
iomem)
(20:53:13)(tj@shakti)(~)$ cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
03c0-03df : vga+
03f8-03ff : serial
0400-047f : 0000:00:1f.0
   0400-047f : pnp 00:06
     0400-0403 : ACPI PM1a_EVT_BLK
     0404-0405 : ACPI PM1a_CNT_BLK
     0408-040b : ACPI PM_TMR
     0410-0415 : ACPI CPU throttle
     0420-042f : ACPI GPE0_BLK
     0450-0450 : ACPI PM2_CNT_BLK
     0460-047f : iTCO_wdt
0500-053f : 0000:00:1f.0
   0500-053f : pnp 00:06
0680-06ff : pnp 00:06
0cf8-0cff : PCI conf1
1000-1fff : PCI Bus #06
   1000-101f : 0000:06:02.0
     1000-101f : e100
2000-2fff : PCI Bus #02
   2000-200f : 0000:02:00.0
     2000-200f : libata
   2010-2017 : 0000:02:00.0
   2018-201f : 0000:02:00.0
     2018-201f : libata
   2020-2023 : 0000:02:00.0
   2024-2027 : 0000:02:00.0
     2024-2027 : libata
3000-301f : 0000:00:1f.3
3020-303f : 0000:00:1f.2
3040-305f : 0000:00:1d.2
   3040-305f : uhci_hcd
3060-307f : 0000:00:1d.1
   3060-307f : uhci_hcd
3080-309f : 0000:00:1d.0
   3080-309f : uhci_hcd
30a0-30bf : 0000:00:1a.2
   30a0-30bf : uhci_hcd
30c0-30df : 0000:00:1a.1
   30c0-30df : uhci_hcd
30e0-30ff : 0000:00:1a.0
   30e0-30ff : uhci_hcd
3400-341f : 0000:00:19.0
   3400-341f : e1000e
3420-3427 : 0000:00:1f.2
3428-342f : 0000:00:1f.2
3430-3437 : 0000:00:02.0
3438-343b : 0000:00:1f.2
343c-343f : 0000:00:1f.2
(20:53:37)(tj@shakti)(~)$ cat /proc/iomem
00000000-0009ebff : System RAM
0009ec00-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000f0000-000fffff : System ROM
00100000-df20cfff : System RAM
   00100000-0032ecb4 : Kernel code
   0032ecb5-0042ffe3 : Kernel data
   00494000-0050c42f : Kernel bss
df20d000-df20efff : reserved
df20f000-df2fafff : System RAM
df2fb000-df3e4fff : ACPI Non-volatile Storage
df3e5000-df3e8fff : System RAM
df3e9000-df3f1fff : ACPI Tables
df3f2000-df3f2fff : System RAM
df3f3000-df3fefff : ACPI Tables
df3ff000-df3fffff : System RAM
df400000-dfffffff : reserved
e0000000-e7ffffff : 0000:00:02.0
e8000000-e80fffff : PCI Bus #06
   e8000000-e8000fff : 0000:06:02.0
     e8000000-e8000fff : e100
e8100000-e82fffff : PCI Bus #06
   e8100000-e81fffff : 0000:06:02.0
     e8100000-e81fffff : e100
   e8200000-e8203fff : 0000:06:03.0
   e8204000-e82047ff : 0000:06:03.0
     e8204000-e82047ff : ohci1394
e8300000-e83fffff : PCI Bus #02
   e8300000-e83001ff : 0000:02:00.0
e8400000-e84fffff : 0000:00:02.0
e8500000-e857ffff : 0000:00:02.0
e8580000-e859ffff : 0000:00:19.0
   e8580000-e859ffff : e1000e
e85a0000-e85a0fff : 0000:00:19.0
   e85a0000-e85a0fff : e1000e
e85a1000-e85a17ff : 0000:00:1f.2
   e85a1000-e85a17ff : ahci
e85a1800-e85a1bff : 0000:00:1d.7
   e85a1800-e85a1bff : ehci_hcd
e85a1c00-e85a1fff : 0000:00:1a.7
   e85a1c00-e85a1fff : ehci_hcd
e85a2000-e85a20ff : 0000:00:1f.3
e85a2100-e85a210f : 0000:00:03.0
   e85a2100-e85a210f : heci
e8600000-e86fffff : PCI Bus #01
e8700000-e87fffff : PCI Bus #03
e8800000-e88fffff : PCI Bus #04
e8900000-e89fffff : PCI Bus #05
e8a00000-e8afffff : 0000:06:02.0
f0000000-f7ffffff : reserved
feb00000-feb03fff : pnp 00:01
fed00000-fed003ff : HPET 0
fed13000-fed13fff : pnp 00:01
fed14000-fed17fff : pnp 00:01
fed18000-fed18fff : pnp 00:01
fed19000-fed19fff : pnp 00:01
fed1c000-fed1ffff : pnp 00:01
fed20000-fed3ffff : pnp 00:01
fed45000-fed99fff : pnp 00:01
fff00000-ffffffff : reserved
100000000-11bffffff : System RAM
(20:53:42)(tj@shakti)(~)$

[7.5.] PCI information ('lspci -vvv' as root)
(20:53:42)(tj@shakti)(~)$ sudo lspci -vvv
00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM  
Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort+ >SERR- <PERR-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information

00:02.0 VGA compatible controller: Intel Corporation 82G33/G31 Express  
Integrated Graphics Controller (rev 02) (prog-if 00 [VGA])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at e8500000 (32-bit, non-prefetchable) [size=512K]
	Region 1: I/O ports at 3430 [size=8]
	Region 2: Memory at e0000000 (32-bit, prefetchable) [size=128M]
	Region 3: Memory at e8400000 (32-bit, non-prefetchable) [size=1M]
	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA  
PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:03.0 Communication controller: Intel Corporation 82G33/G31/P35/P31  
Express MEI Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 22
	Region 0: Memory at e85a2100 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] Message Signalled Interrupts: Mask- 64bit+  
Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

00:19.0 Ethernet controller: Intel Corporation 82801I (ICH9 Family)  
Gigabit Ethernet Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 217
	Region 0: Memory at e8580000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at e85a0000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 3400 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+  
Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 4152
	Capabilities: [e0] Vendor Specific Information

00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 18
	Region 4: I/O ports at 30e0 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #5 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 20
	Region 4: I/O ports at 30c0 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1a.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #6 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin C routed to IRQ 16
	Region 4: I/O ports at 30a0 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2  
EHCI Controller #2 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin C routed to IRQ 16
	Region 0: Memory at e85a1c00 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port
	Capabilities: [98] Vendor Specific Information

00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express  
Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e8600000-e86fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 1
		Link: Latency L0s <1us, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 1, PowerLimit 10.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable+
		Address: fee0300c  Data: 41c9
	Capabilities: [90] Subsystem: Intel Corporation 82801I (ICH9 Family)  
PCI Express Port 1
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express  
Port 2 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: e8300000-e83fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
		Link: Latency L0s <256ns, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 2, PowerLimit 10.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable+
		Address: fee0300c  Data: 41d1
	Capabilities: [90] Subsystem: Intel Corporation 82801I (ICH9 Family)  
PCI Express Port 2
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express  
Port 3 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e8700000-e87fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
		Link: Latency L0s <1us, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 3, PowerLimit 10.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable+
		Address: fee0300c  Data: 41d9
	Capabilities: [90] Subsystem: Intel Corporation 82801I (ICH9 Family)  
PCI Express Port 3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express  
Port 4 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e8800000-e88fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <1us, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 4, PowerLimit 10.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable+
		Address: fee0300c  Data: 41e1
	Capabilities: [90] Subsystem: Intel Corporation 82801I (ICH9 Family)  
PCI Express Port 4
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express  
Port 5 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e8900000-e89fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [40] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 5
		Link: Latency L0s <1us, L1 <4us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x0
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 5, PowerLimit 10.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Unknown, PwrInd Unknown, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable+
		Address: fee0300c  Data: 41e9
	Capabilities: [90] Subsystem: Intel Corporation 82801I (ICH9 Family)  
PCI Express Port 5
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 21
	Region 4: I/O ports at 3080 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 3060 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1d.2 USB Controller: Intel Corporation 82801I (ICH9 Family) USB  
UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 3040 [size=32]
	Capabilities: [50] Vendor Specific Information

00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2  
EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at e85a1800 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot 
+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port
	Capabilities: [98] Vendor Specific Information

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92) (prog- 
if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=32
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: e8100000-e82fffff
	Prefetchable memory behind bridge: 00000000e8000000-00000000e80fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Subsystem: Intel Corporation Unknown device 5044

00:1f.0 ISA bridge: Intel Corporation 82801IH (ICH9DH) LPC Interface  
Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information

00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH)  
6 port SATA AHCI Controller (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Interrupt: pin A routed to IRQ 218
	Region 0: I/O ports at 3428 [size=8]
	Region 1: I/O ports at 343c [size=4]
	Region 2: I/O ports at 3420 [size=8]
	Region 3: I/O ports at 3438 [size=4]
	Region 4: I/O ports at 3020 [size=32]
	Region 5: Memory at e85a1000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/4 Enable+
		Address: fee0300c  Data: 4142
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot 
+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] #12 [0010]
	Capabilities: [b0] Vendor Specific Information

00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller  
(rev 02)
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 18
	Region 0: Memory at e85a2000 (64-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 3000 [size=32]

02:00.0 IDE interface: Marvell Technology Group Ltd. 88SE6101 single- 
port PATA133 interface (rev b2) (prog-if 8f [Master SecP SecO PriP  
PriO])
	Subsystem: Marvell Technology Group Ltd. 88SE6101 single-port PATA133  
interface
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at 2018 [size=8]
	Region 1: I/O ports at 2024 [size=4]
	Region 2: I/O ports at 2010 [size=8]
	Region 3: I/O ports at 2020 [size=4]
	Region 4: I/O ports at 2000 [size=16]
	Region 5: Memory at e8300000 (32-bit, non-prefetchable) [size=512]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0+,D1+,D2-,D3hot 
+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit-  
Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr+ NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1

06:02.0 Ethernet controller: Intel Corporation 82557/8/9 Ethernet Pro  
100 (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min, 14000ns max)
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at e8000000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at 1000 [size=32]
	Region 2: Memory at e8100000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at e8a00000 [disabled] [size=1M]

06:03.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22/A  
IEEE-1394a-2000 Controller (PHY/Link) (prog-if 10 [OHCI])
	Subsystem: Intel Corporation Unknown device 5044
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-  
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-  
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (500ns min, 1000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at e8204000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at e8200000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot 
+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+

(20:54:00)(tj@shakti)(~)$

[7.6.] SCSI information (from /proc/scsi/scsi)
(20:54:00)(tj@shakti)(~)$ cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST31000340AS     Rev: SD15
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi1 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST31000340AS     Rev: SD14
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi4 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST31000340AS     Rev: SD14
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi5 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: ST31000340AS     Rev: SD04
   Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi6 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: SanDisk SDCFB-51 Rev: HDX
   Type:   Direct-Access                    ANSI  SCSI revision: 05
(20:54:29)(tj@shakti)(~)$

[7.7.] Other information that might be relevant to the problem
        (please look in /proc and include all information that you
        think to be relevant):
(20:55:03)(tj@shakti)(~)$ sudo dmidecode
# dmidecode 2.9
SMBIOS 2.4 present.
35 structures occupying 1626 bytes.
Table at 0x000E33A0.

Handle 0x0000, DMI type 4, 35 bytes
Processor Information
	Socket Designation: J1PR
	Type: Central Processor
	Family: Pentium D
	Manufacturer: Intel(R) Corporation
	ID: FD 06 00 00 FF FB EB BF
	Signature: Type 0, Family 6, Model 15, Stepping 13
	Flags:
		FPU (Floating-point unit on-chip)
		VME (Virtual mode extension)
		DE (Debugging extension)
		PSE (Page size extension)
		TSC (Time stamp counter)
		MSR (Model specific registers)
		PAE (Physical address extension)
		MCE (Machine check exception)
		CX8 (CMPXCHG8 instruction supported)
		APIC (On-chip APIC hardware supported)
		SEP (Fast system call)
		MTRR (Memory type range registers)
		PGE (Page global enable)
		MCA (Machine check architecture)
		CMOV (Conditional move instruction supported)
		PAT (Page attribute table)
		PSE-36 (36-bit page size extension)
		CLFSH (CLFLUSH instruction supported)
		DS (Debug store)
		ACPI (ACPI supported)
		MMX (MMX technology supported)
		FXSR (Fast floating-point save and restore)
		SSE (Streaming SIMD extensions)
		SSE2 (Streaming SIMD extensions 2)
		SS (Self-snoop)
		HTT (Hyper-threading technology)
		TM (Thermal monitor supported)
		PBE (Pending break enabled)
	Version: Intel(R) Core(TM)2 Duo CPU     E4500  @ 2.20GHz
	Voltage: 1.6 V
	External Clock: 200 MHz
	Max Speed: 4000 MHz
	Current Speed: 2200 MHz
	Status: Populated, Enabled
	Upgrade: Socket LGA775
	L1 Cache Handle: 0x0003
	L2 Cache Handle: 0x0001
	L3 Cache Handle: Not Provided
	Serial Number: Not Specified
	Asset Tag: Not Specified
	Part Number: Not Specified

Handle 0x0001, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Unknown
	Configuration: Enabled, Not Socketed, Level 2
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 2048 KB
	Maximum Size: 2048 KB
	Supported SRAM Types:
		Asynchronous
	Installed SRAM Type: Asynchronous
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Unified
	Associativity: 8-way Set-associative

Handle 0x0002, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Unknown
	Configuration: Enabled, Not Socketed, Level 1
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 32 KB
	Maximum Size: 32 KB
	Supported SRAM Types:
		Asynchronous
	Installed SRAM Type: Asynchronous
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Instruction
	Associativity: 8-way Set-associative

Handle 0x0003, DMI type 7, 19 bytes
Cache Information
	Socket Designation: Unknown
	Configuration: Enabled, Not Socketed, Level 1
	Operational Mode: Write Back
	Location: Internal
	Installed Size: 32 KB
	Maximum Size: 32 KB
	Supported SRAM Types:
		Asynchronous
	Installed SRAM Type: Asynchronous
	Speed: Unknown
	Error Correction Type: Single-bit ECC
	System Type: Data
	Associativity: 8-way Set-associative

Handle 0x0004, DMI type 0, 24 bytes
BIOS Information
	Vendor: Intel Corp.
	Version: DPP3510J.86A.0293.2007.1002.1519
	Release Date: 10/02/2007
	Address: 0xF0000
	Runtime Size: 64 kB
	ROM Size: 1024 kB
	Characteristics:
		PCI is supported
		BIOS is upgradeable
		BIOS shadowing is allowed
		Boot from CD is supported
		Selectable boot is supported
		EDD is supported
		8042 keyboard services are supported (int 9h)
		Serial services are supported (int 14h)
		Printer services are supported (int 17h)
		CGA/mono video services are supported (int 10h)
		ACPI is supported
		USB legacy is supported
		ATAPI Zip drive boot is supported
		BIOS boot specification is supported
		Function key-initiated network boot is supported
		Targeted content distribution is supported
	BIOS Revision: 0.0
	Firmware Revision: 0.0

Handle 0x0005, DMI type 1, 27 bytes
System Information
	Manufacturer:
	Product Name:
	Version:
	Serial Number:
	UUID: D8CE783A-A41E-11DC-ADB7-0013D4E33164
	Wake-up Type: Power Switch
	SKU Number: Not Specified
	Family: Not Specified

Handle 0x0006, DMI type 2, 20 bytes
Base Board Information
	Manufacturer: Intel Corporation
	Product Name: DG33FB
	Version: AAD81072-306
	Serial Number: USFB749001BF
	Asset Tag: Base Board Asset Tag
	Features:
		Board is a hosting board
		Board is replaceable
	Location In Chassis: Base Board Chassis Location
	Chassis Handle: 0x0007
	Type: Unknown
	Contained Object Handles: 0

Handle 0x0007, DMI type 3, 17 bytes
Chassis Information
	Manufacturer:
	Type: Unknown
	Lock: Not Present
	Version:
	Serial Number:
	Asset Tag:
	Boot-up State: Safe
	Power Supply State: Safe
	Thermal State: Other
	Security Status: Other
	OEM Information: 0x00000000

Handle 0x0008, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: PRIMARY
	Internal Connector Type: On Board IDE
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x0009, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: SECONDARY
	Internal Connector Type: On Board IDE
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x000A, DMI type 8, 9 bytes
Port Connector Information
	Internal Reference Designator: ATX_PWR
	Internal Connector Type: Other
	External Reference Designator: Not Specified
	External Connector Type: None
	Port Type: Other

Handle 0x000B, DMI type 9, 13 bytes
System Slot Information
	Designation: PCIE X16 SLOT
	Type: x16 PCI Express
	Current Usage: Available
	Length: Short
	ID: 11
	Characteristics:
		3.3 V is provided

Handle 0x000C, DMI type 9, 13 bytes
System Slot Information
	Designation: PCIE X1 SLOT 1
	Type: x1 PCI Express
	Current Usage: Available
	Length: Short
	ID: 12
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x000D, DMI type 9, 13 bytes
System Slot Information
	Designation: PCIE X1 SLOT 2
	Type: x1 PCI Express
	Current Usage: Available
	Length: Short
	ID: 13
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x000E, DMI type 9, 13 bytes
System Slot Information
	Designation: PCIE X1 SLOT 3
	Type: x1 PCI Express
	Current Usage: Available
	Length: Short
	ID: 14
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x000F, DMI type 9, 13 bytes
System Slot Information
	Designation: PCI SLOT 1
	Type: 32-bit PCI
	Current Usage: Available
	Length: Long
	ID: 1
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x0010, DMI type 9, 13 bytes
System Slot Information
	Designation: PCI SLOT 2
	Type: 32-bit PCI
	Current Usage: Available
	Length: Long
	ID: 2
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x0011, DMI type 9, 13 bytes
System Slot Information
	Designation: PCI SLOT 3
	Type: 32-bit PCI
	Current Usage: In Use
	Length: Long
	ID: 3
	Characteristics:
		3.3 V is provided
		PME signal is supported
		SMBus signal is supported

Handle 0x0012, DMI type 10, 6 bytes
On Board Device Information
	Type: Video
	Status: Enabled
	Description: Unknown Video Device

Handle 0x0013, DMI type 10, 6 bytes
On Board Device Information
	Type: Ethernet
	Status: Enabled
	Description: Intel(R) 82566DC Gigabit Ethernet Device

Handle 0x0014, DMI type 10, 6 bytes
On Board Device Information
	Type: Sound
	Status: Disabled
	Description: Intel(R) High Definition Audio Device

Handle 0x0015, DMI type 13, 22 bytes
BIOS Language Information
	Installable Languages: 1
		enUS
	Currently Installed Language: enUS

Handle 0x0016, DMI type 32, 20 bytes
System Boot Information
	Status: No errors detected

Handle 0x0017, DMI type 16, 15 bytes
Physical Memory Array
	Location: System Board Or Motherboard
	Use: System Memory
	Error Correction Type: None
	Maximum Capacity: 8 GB
	Error Information Handle: Not Provided
	Number Of Devices: 4

Handle 0x0018, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0017
	Error Information Handle: Not Provided
	Total Width: 64 bits
	Data Width: 64 bits
	Size: 2048 MB
	Form Factor: DIMM
	Set: None
	Locator: J6H1
	Bank Locator: CHAN A DIMM 0
	Type: DDR2
	Type Detail: Synchronous
	Speed: 667 MHz (1.5 ns)
	Manufacturer: 0x7F98000000000000
	Serial Number: 0x69344D45
	Asset Tag: Unknown
	Part Number: 0x32472D5544494D4D00000000000000000000

Handle 0x0019, DMI type 20, 19 bytes
Memory Device Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x0007FFFFFFF
	Range Size: 2 GB
	Physical Device Handle: 0x0018
	Memory Array Mapped Address Handle: 0x001E
	Partition Row Position: 1
	Interleave Position: 1
	Interleaved Data Depth: 1

Handle 0x001A, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0017
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: No Module Installed
	Form Factor: DIMM
	Set: None
	Locator: J6H2
	Bank Locator: CHAN A DIMM 1
	Type: DDR2
	Type Detail: None
	Speed: Unknown
	Manufacturer: NO DIMM
	Serial Number: NO DIMM
	Asset Tag: NO DIMM
	Part Number: NO DIMM

Handle 0x001B, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0017
	Error Information Handle: Not Provided
	Total Width: 64 bits
	Data Width: 64 bits
	Size: 2048 MB
	Form Factor: DIMM
	Set: None
	Locator: J6J1
	Bank Locator: CHAN B DIMM 0
	Type: DDR2
	Type Detail: Synchronous
	Speed: 667 MHz (1.5 ns)
	Manufacturer: 0x7F98000000000000
	Serial Number: 0x69344C45
	Asset Tag: Unknown
	Part Number: 0x32472D5544494D4D00000000000000000000

Handle 0x001C, DMI type 20, 19 bytes
Memory Device Mapped Address
	Starting Address: 0x00080000000
	Ending Address: 0x000FFFFFFFF
	Range Size: 2 GB
	Physical Device Handle: 0x001B
	Memory Array Mapped Address Handle: 0x001E
	Partition Row Position: 2
	Interleave Position: 2
	Interleaved Data Depth: 1

Handle 0x001D, DMI type 17, 27 bytes
Memory Device
	Array Handle: 0x0017
	Error Information Handle: Not Provided
	Total Width: Unknown
	Data Width: Unknown
	Size: No Module Installed
	Form Factor: DIMM
	Set: None
	Locator: J6J2
	Bank Locator: CHAN B DIMM 1
	Type: DDR2
	Type Detail: None
	Speed: Unknown
	Manufacturer: NO DIMM
	Serial Number: NO DIMM
	Asset Tag: NO DIMM
	Part Number: NO DIMM

Handle 0x001E, DMI type 19, 15 bytes
Memory Array Mapped Address
	Starting Address: 0x00000000000
	Ending Address: 0x000FFFFFFFF
	Range Size: 4 GB
	Physical Array Handle: 0x0017
	Partition Width: 0

Handle 0x001F, DMI type 187, 9 bytes
OEM-specific Type
	Header and Data:
		BB 09 1F 00 18 00 03 9B 02

Handle 0x0020, DMI type 187, 9 bytes
OEM-specific Type
	Header and Data:
		BB 09 20 00 1B 00 03 9B 02

Handle 0x0021, DMI type 136, 6 bytes
OEM-specific Type
	Header and Data:
		88 06 21 00 5A 5A

Handle 0xFEFF, DMI type 127, 4 bytes
End Of Table

(20:55:05)(tj@shakti)(~)$



-- 
Tuomas Jormola <tj@solitudo.net>


--Apple-Mail-6-1037319543
Content-Disposition: attachment;
	filename=oops1.txt
Content-Type: text/plain;
	x-unix-mode=0600;
	name="oops1.txt"
Content-Transfer-Encoding: 7bit

Feb 26 13:50:51 shakti kernel: [89048.423200] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:50:51 shakti kernel: [89048.423559]
Feb 26 13:50:51 shakti kernel: [89048.423660] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:50:51 shakti kernel: [89048.423791] EIP: 0060:[<f9114a02>] EFLAGS: 00000202 CPU: 1
Feb 26 13:50:51 shakti kernel: [89048.424347] EIP is at tcp_packet+0x9b2/0xbb0 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.424484] EAX: 00000000 EBX: 0000fa80 ECX: ec070ce4 EDX: ec070ce4
Feb 26 13:50:51 shakti kernel: [89048.424608] ESI: 6a151a34 EDI: ec070c30 EBP: 00000001 ESP: df9cf680
Feb 26 13:50:51 shakti kernel: [89048.424724]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:50:51 shakti kernel: [89048.424849] CR0: 80050033 CR2: b7d521a8 CR3: 32491000 CR4: 000006b0
Feb 26 13:50:51 shakti kernel: [89048.424956] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:50:51 shakti kernel: [89048.425066] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:50:51 shakti kernel: [89048.425187]  [<f8974cad>] e100_disable_irq+0x3d/0x60 [e100]
Feb 26 13:50:51 shakti kernel: [89048.425580]  [<f8975925>] e100_intr+0xb5/0xc0 [e100]
Feb 26 13:50:51 shakti kernel: [89048.426126]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 13:50:51 shakti kernel: [89048.426409]  [<f91103fc>] __nf_conntrack_find+0x1c/0x110 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.427036]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.427663]  [<f91117b1>] nf_conntrack_in+0x201/0x4d0 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.428488]  [<f91021d0>] ipv4_conntrack_local+0x0/0x70 [nf_conntrack_ipv4]
Feb 26 13:50:51 shakti kernel: [89048.428815]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 13:50:51 shakti kernel: [89048.429003]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:50:51 shakti kernel: [89048.429204]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 13:50:51 shakti kernel: [89048.429408]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:50:51 shakti kernel: [89048.429628]  [<c02dae47>] ip_queue_xmit+0x1e7/0x430
Feb 26 13:50:51 shakti kernel: [89048.429827]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:50:51 shakti kernel: [89048.430035]  [<c032ced0>] notifier_call_chain+0x30/0x60
Feb 26 13:50:51 shakti kernel: [89048.430273]  [<c032cf27>] atomic_notifier_call_chain+0x17/0x20
Feb 26 13:50:51 shakti kernel: [89048.430496]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:50:51 shakti kernel: [89048.430685]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:50:51 shakti kernel: [89048.430939]  [<c02ebc67>] tcp_transmit_skb+0x497/0x820
Feb 26 13:50:51 shakti kernel: [89048.431264]  [<c02ed6da>] __tcp_push_pending_frames+0x11a/0x8f0
Feb 26 13:50:51 shakti kernel: [89048.431639]  [<c02eb297>] tcp_current_mss+0x77/0x110
Feb 26 13:50:51 shakti kernel: [89048.431855]  [<c02ea984>] tcp_rcv_established+0x434/0x950
Feb 26 13:50:51 shakti kernel: [89048.432108]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Feb 26 13:50:51 shakti kernel: [89048.432302]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Feb 26 13:50:51 shakti kernel: [89048.432476]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Feb 26 13:50:51 shakti kernel: [89048.432754]  [<c02f1590>] tcp_v4_do_rcv+0x340/0x6e0
Feb 26 13:50:51 shakti kernel: [89048.432957]  [<c02d30c9>] ip_route_input+0x39/0xdf0
Feb 26 13:50:51 shakti kernel: [89048.433148]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.433835]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:50:51 shakti kernel: [89048.434476]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Feb 26 13:50:51 shakti kernel: [89048.434776]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Feb 26 13:50:51 shakti kernel: [89048.435082]  [<c02f417d>] tcp_v4_rcv+0x7bd/0x9a0
Feb 26 13:50:51 shakti kernel: [89048.435366]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 13:50:51 shakti kernel: [89048.435589]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 13:50:51 shakti kernel: [89048.435795]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:50:51 shakti kernel: [89048.436018]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:50:51 shakti kernel: [89048.436208]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:50:51 shakti kernel: [89048.436397]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:50:51 shakti kernel: [89048.436574]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:50:51 shakti kernel: [89048.436823]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 13:50:51 shakti kernel: [89048.437374]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 13:50:51 shakti kernel: [89048.437904]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 13:50:51 shakti kernel: [89048.438537]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 13:50:51 shakti kernel: [89048.439041]  [<c02c5dfc>] __qdisc_run+0x7c/0x1a0
Feb 26 13:50:51 shakti kernel: [89048.439238]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:50:51 shakti kernel: [89048.439491]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:50:51 shakti kernel: [89048.439716]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:50:51 shakti kernel: [89048.439902]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:50:51 shakti kernel: [89048.440058]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:50:51 shakti kernel: [89048.440263]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:50:51 shakti kernel: [89048.440520]  [<f8899de6>] xor_sse_4+0x2b6/0x360 [xor]
Feb 26 13:50:51 shakti kernel: [89048.440919]  [<f8898b15>] xor_blocks+0x75/0xa0 [xor]
Feb 26 13:50:51 shakti kernel: [89048.441173]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.441521]  [<f88942fb>] async_xor+0x2fb/0x350 [async_xor]
Feb 26 13:50:51 shakti kernel: [89048.441761]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 13:50:51 shakti kernel: [89048.442028]  [<f88e5d50>] ops_complete_write+0x0/0x60 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.442394]  [<f88e6181>] ops_run_postxor+0xd1/0x160 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.442755]  [<f88e5d50>] ops_complete_write+0x0/0x60 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.443202]  [<f88e7330>] handle_stripe5+0x1040/0x1590 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.443565]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:50:51 shakti kernel: [89048.443954]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.444433]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.444849]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:50:51 shakti kernel: [89048.445063]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.445578]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:50:51 shakti kernel: [89048.445797]  [<f88ab0c6>] md_wakeup_thread+0x26/0x30 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.446285]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.446624]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.447103]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:50:51 shakti kernel: [89048.447485]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 13:50:51 shakti kernel: [89048.447697]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.448200]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.448681]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.449163]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:50:51 shakti kernel: [89048.449387]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:50:51 shakti kernel: [89048.449862]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:50:51 shakti kernel: [89048.450018]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:50:51 shakti kernel: [89048.450182]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:50:51 shakti kernel: [89048.450397]  =======================
Feb 26 13:51:02 shakti kernel: [89060.232012] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:51:02 shakti kernel: [89060.232340]
Feb 26 13:51:02 shakti kernel: [89060.232444] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:51:02 shakti kernel: [89060.232575] EIP: 0060:[<c0191948>] EFLAGS: 00000286 CPU: 1
Feb 26 13:51:02 shakti kernel: [89060.232683] EIP is at kfree+0x98/0xe0
Feb 26 13:51:02 shakti kernel: [89060.232798] EAX: 00000286 EBX: e21b6230 ECX: d5831800 EDX: d5831c00
Feb 26 13:51:02 shakti kernel: [89060.232927] ESI: 00000000 EDI: f8a6a374 EBP: c02adca8 ESP: df9cfbc4
Feb 26 13:51:02 shakti kernel: [89060.233053]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:51:02 shakti kernel: [89060.233204] CR0: 8005003b CR2: b7d521a8 CR3: 32491000 CR4: 000006b0
Feb 26 13:51:02 shakti kernel: [89060.233305] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:51:02 shakti kernel: [89060.233409] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:51:02 shakti kernel: [89060.233487]  [<c02adca8>] __kfree_skb+0x8/0x80
Feb 26 13:51:02 shakti kernel: [89060.233706]  [<c02adca8>] __kfree_skb+0x8/0x80
Feb 26 13:51:02 shakti kernel: [89060.233905]  [<f8b0a573>] e1000_put_txbuf+0x23/0x30 [e1000e]
Feb 26 13:51:02 shakti kernel: [89060.234447]  [<f8b0a6fe>] e1000_clean_tx_irq+0xde/0x330 [e1000e]
Feb 26 13:51:02 shakti kernel: [89060.235002]  [<f8975c0a>] e100_tx_clean+0x5a/0x100 [e100]
Feb 26 13:51:02 shakti kernel: [89060.235390]  [<c02adca8>] __kfree_skb+0x8/0x80
Feb 26 13:51:02 shakti kernel: [89060.235589]  [<f8975c0a>] e100_tx_clean+0x5a/0x100 [e100]
Feb 26 13:51:02 shakti kernel: [89060.235955]  [<c02af242>] __netdev_alloc_skb+0x22/0x50
Feb 26 13:51:02 shakti kernel: [89060.236215]  [<c014f3a8>] tick_program_event+0x38/0x60
Feb 26 13:51:02 shakti kernel: [89060.236427]  [<f8975d27>] e100_poll+0x77/0x2f0 [e100]
Feb 26 13:51:02 shakti kernel: [89060.236802]  [<f8b0ac89>] e1000_clean+0x39/0x220 [e1000e]
Feb 26 13:51:02 shakti kernel: [89060.237375]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:51:02 shakti kernel: [89060.237658]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:02 shakti kernel: [89060.237898]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:51:02 shakti kernel: [89060.238087]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:51:02 shakti kernel: [89060.238242]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:51:02 shakti kernel: [89060.238460]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:02 shakti kernel: [89060.238738]  [<c020ed80>] generic_make_request+0x220/0x4c0
Feb 26 13:51:02 shakti kernel: [89060.238966]  [<c010a940>] do_IRQ+0x40/0x70
Feb 26 13:51:02 shakti kernel: [89060.239334]  [<c014f3a8>] tick_program_event+0x38/0x60
Feb 26 13:51:02 shakti kernel: [89060.239575]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Feb 26 13:51:02 shakti kernel: [89060.239945]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 13:51:02 shakti kernel: [89060.240238]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:02 shakti kernel: [89060.240464]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.241090]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.241582]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:51:02 shakti kernel: [89060.241925]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 13:51:02 shakti kernel: [89060.242195]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:02 shakti kernel: [89060.242418]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.242951]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:51:02 shakti kernel: [89060.243195]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:51:02 shakti kernel: [89060.243545]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.244036]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:51:02 shakti kernel: [89060.244424]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 13:51:02 shakti kernel: [89060.244637]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.245147]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.245628]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.246123]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:51:02 shakti kernel: [89060.246354]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:02 shakti kernel: [89060.246840]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:51:02 shakti kernel: [89060.246995]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:51:02 shakti kernel: [89060.247164]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:51:02 shakti kernel: [89060.247384]  =======================
Feb 26 13:51:23 shakti kernel: [89080.742583] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:51:23 shakti kernel: [89080.742911]
Feb 26 13:51:23 shakti kernel: [89080.742995] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:51:23 shakti kernel: [89080.743113] EIP: 0060:[<f90f75bb>] EFLAGS: 00000246 CPU: 1
Feb 26 13:51:23 shakti kernel: [89080.743310] EIP is at ipt_do_table+0xfb/0x4b0 [ip_tables]
Feb 26 13:51:23 shakti kernel: [89080.743409] EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 00000000
Feb 26 13:51:23 shakti kernel: [89080.743540] ESI: f90f99d4 EDI: f922d538 EBP: f9228b60 ESP: df9cf89c
Feb 26 13:51:23 shakti kernel: [89080.743657]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:51:23 shakti kernel: [89080.743778] CR0: 8005003b CR2: b64d4000 CR3: 32491000 CR4: 000006b0
Feb 26 13:51:23 shakti kernel: [89080.743880] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:51:23 shakti kernel: [89080.743977] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:51:23 shakti kernel: [89080.744330]  [<f8cfe000>] ipt_local_out_hook+0x0/0x80 [iptable_filter]
Feb 26 13:51:23 shakti kernel: [89080.744551]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 13:51:23 shakti kernel: [89080.744761]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 13:51:23 shakti kernel: [89080.744930]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:51:23 shakti kernel: [89080.745121]  [<c02dae47>] ip_queue_xmit+0x1e7/0x430
Feb 26 13:51:23 shakti kernel: [89080.745289]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:51:23 shakti kernel: [89080.745509]  [<c014cbca>] clocksource_get_next+0x3a/0x40
Feb 26 13:51:23 shakti kernel: [89080.745666]  [<c014b503>] update_wall_time+0x2e3/0x840
Feb 26 13:51:23 shakti kernel: [89080.745818]  [<c032cf27>] atomic_notifier_call_chain+0x17/0x20
Feb 26 13:51:23 shakti kernel: [89080.746013]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:51:23 shakti kernel: [89080.746159]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:51:23 shakti kernel: [89080.746306]  [<c012a88e>] try_to_wake_up+0x4e/0x350
Feb 26 13:51:23 shakti kernel: [89080.746553]  [<c02ebc67>] tcp_transmit_skb+0x497/0x820
Feb 26 13:51:23 shakti kernel: [89080.746890]  [<c02ed6da>] __tcp_push_pending_frames+0x11a/0x8f0
Feb 26 13:51:23 shakti kernel: [89080.747286]  [<c02eb297>] tcp_current_mss+0x77/0x110
Feb 26 13:51:23 shakti kernel: [89080.747471]  [<c02ea984>] tcp_rcv_established+0x434/0x950
Feb 26 13:51:23 shakti kernel: [89080.747706]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Feb 26 13:51:23 shakti kernel: [89080.747864]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Feb 26 13:51:23 shakti kernel: [89080.748019]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Feb 26 13:51:23 shakti kernel: [89080.748297]  [<c02f1590>] tcp_v4_do_rcv+0x340/0x6e0
Feb 26 13:51:23 shakti kernel: [89080.748466]  [<c02d30c9>] ip_route_input+0x39/0xdf0
Feb 26 13:51:23 shakti kernel: [89080.748619]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 13:51:23 shakti kernel: [89080.749344]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:51:23 shakti kernel: [89080.749967]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:23 shakti kernel: [89080.750235]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:23 shakti kernel: [89080.750540]  [<c02f417d>] tcp_v4_rcv+0x7bd/0x9a0
Feb 26 13:51:23 shakti kernel: [89080.750820]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 13:51:23 shakti kernel: [89080.751017]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 13:51:23 shakti kernel: [89080.751191]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:23 shakti kernel: [89080.751388]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:51:23 shakti kernel: [89080.751547]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:23 shakti kernel: [89080.751702]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:51:23 shakti kernel: [89080.751865]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:51:23 shakti kernel: [89080.752098]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 13:51:23 shakti kernel: [89080.752637]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 13:51:23 shakti kernel: [89080.753147]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 13:51:23 shakti kernel: [89080.753803]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 13:51:23 shakti kernel: [89080.754331]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:51:23 shakti kernel: [89080.754575]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:23 shakti kernel: [89080.754779]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:51:23 shakti kernel: [89080.754928]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:51:23 shakti kernel: [89080.755065]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:51:23 shakti kernel: [89080.755263]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:23 shakti kernel: [89080.755507]  [<c020eb9c>] generic_make_request+0x3c/0x4c0
Feb 26 13:51:23 shakti kernel: [89080.755714]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Feb 26 13:51:23 shakti kernel: [89080.756057]  [<c016a6bc>] handle_fasteoi_irq+0x9c/0xe0
Feb 26 13:51:23 shakti kernel: [89080.756346]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 13:51:23 shakti kernel: [89080.756493]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 13:51:23 shakti kernel: [89080.756639]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 13:51:23 shakti kernel: [89080.756982]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.757443]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:51:23 shakti kernel: [89080.757859]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:23 shakti kernel: [89080.758046]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.758543]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:51:23 shakti kernel: [89080.758751]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:51:23 shakti kernel: [89080.759059]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.759508]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:51:23 shakti kernel: [89080.759916]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.760417]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.760874]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.761337]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:51:23 shakti kernel: [89080.761535]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:23 shakti kernel: [89080.761987]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:51:23 shakti kernel: [89080.762122]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:51:23 shakti kernel: [89080.762275]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:51:23 shakti kernel: [89080.762468]  =======================
Feb 26 13:51:35 shakti kernel: [89092.551400] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:51:35 shakti kernel: [89092.551720]
Feb 26 13:51:35 shakti kernel: [89092.551824] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:51:35 shakti kernel: [89092.551956] EIP: 0060:[<c02adf72>] EFLAGS: 00000292 CPU: 1
Feb 26 13:51:35 shakti kernel: [89092.552082] EIP is at pskb_expand_head+0x152/0x160
Feb 26 13:51:35 shakti kernel: [89092.552203] EAX: 00000000 EBX: 00000022 ECX: 00010002 EDX: f4c07e80
Feb 26 13:51:35 shakti kernel: [89092.552354] ESI: 00000b50 EDI: e201dd80 EBP: e11ab230 ESP: df9cf7b4
Feb 26 13:51:35 shakti kernel: [89092.552469]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:51:35 shakti kernel: [89092.552591] CR0: 8005003b CR2: b64d4000 CR3: 00494000 CR4: 000006b0
Feb 26 13:51:35 shakti kernel: [89092.552696] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:51:35 shakti kernel: [89092.552791] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:51:35 shakti kernel: [89092.552865]  [<c02adfc5>] __pskb_pull_tail+0x45/0x2c0
Feb 26 13:51:35 shakti kernel: [89092.553148]  [<f8b0cb71>] e1000_xmit_frame+0x231/0xab0 [e1000e]
Feb 26 13:51:35 shakti kernel: [89092.553888]  [<c021e5ff>] strlcpy+0x1f/0x60
Feb 26 13:51:35 shakti kernel: [89092.554107]  [<f8b6343a>] packet_rcv_spkt+0x2a/0x1a0 [af_packet]
Feb 26 13:51:35 shakti kernel: [89092.554439]  [<f8b63410>] packet_rcv_spkt+0x0/0x1a0 [af_packet]
Feb 26 13:51:35 shakti kernel: [89092.554753]  [<c02b3fcc>] dev_hard_start_xmit+0x21c/0x2a0
Feb 26 13:51:35 shakti kernel: [89092.554971]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:51:35 shakti kernel: [89092.555652]  [<c02c5ddb>] __qdisc_run+0x5b/0x1a0
Feb 26 13:51:35 shakti kernel: [89092.555846]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Feb 26 13:51:35 shakti kernel: [89092.556076]  [<c02b65a7>] dev_queue_xmit+0x227/0x300
Feb 26 13:51:35 shakti kernel: [89092.556273]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Feb 26 13:51:35 shakti kernel: [89092.556473]  [<c02d9ffc>] ip_finish_output+0x14c/0x2c0
Feb 26 13:51:35 shakti kernel: [89092.556722]  [<c02daedf>] ip_queue_xmit+0x27f/0x430
Feb 26 13:51:35 shakti kernel: [89092.556922]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:51:35 shakti kernel: [89092.557130]  [<c032ced0>] notifier_call_chain+0x30/0x60
Feb 26 13:51:35 shakti kernel: [89092.557390]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:51:35 shakti kernel: [89092.557576]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 13:51:35 shakti kernel: [89092.557770]  [<c018fec3>] add_partial_tail+0x13/0x40
Feb 26 13:51:35 shakti kernel: [89092.558005]  [<c02ebc67>] tcp_transmit_skb+0x497/0x820
Feb 26 13:51:35 shakti kernel: [89092.558327]  [<c02ed6da>] __tcp_push_pending_frames+0x11a/0x8f0
Feb 26 13:51:35 shakti kernel: [89092.558693]  [<c02eb297>] tcp_current_mss+0x77/0x110
Feb 26 13:51:35 shakti kernel: [89092.558906]  [<c02ea984>] tcp_rcv_established+0x434/0x950
Feb 26 13:51:35 shakti kernel: [89092.559161]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Feb 26 13:51:35 shakti kernel: [89092.559357]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Feb 26 13:51:35 shakti kernel: [89092.559533]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Feb 26 13:51:35 shakti kernel: [89092.559812]  [<c02f1590>] tcp_v4_do_rcv+0x340/0x6e0
Feb 26 13:51:35 shakti kernel: [89092.560016]  [<c02d30c9>] ip_route_input+0x39/0xdf0
Feb 26 13:51:35 shakti kernel: [89092.560209]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 13:51:35 shakti kernel: [89092.560900]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:51:35 shakti kernel: [89092.561549]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:35 shakti kernel: [89092.561847]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:35 shakti kernel: [89092.562147]  [<c02f417d>] tcp_v4_rcv+0x7bd/0x9a0
Feb 26 13:51:35 shakti kernel: [89092.562415]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 13:51:35 shakti kernel: [89092.562634]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 13:51:35 shakti kernel: [89092.562836]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:35 shakti kernel: [89092.563053]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:51:35 shakti kernel: [89092.563245]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:35 shakti kernel: [89092.563436]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:51:35 shakti kernel: [89092.563612]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:51:35 shakti kernel: [89092.563861]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 13:51:35 shakti kernel: [89092.564418]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 13:51:35 shakti kernel: [89092.564958]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 13:51:35 shakti kernel: [89092.565597]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 13:51:35 shakti kernel: [89092.566150]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:51:35 shakti kernel: [89092.566404]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:35 shakti kernel: [89092.566631]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:51:35 shakti kernel: [89092.566817]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:51:35 shakti kernel: [89092.566975]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:51:35 shakti kernel: [89092.567158]  [<c0127857>] enqueue_task_fair+0x27/0x30
Feb 26 13:51:35 shakti kernel: [89092.567352]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:35 shakti kernel: [89092.567594]  [<f883c035>] async_tx_find_channel+0x35/0x40 [async_tx]
Feb 26 13:51:35 shakti kernel: [89092.567881]  [<f8844020>] async_memcpy+0x20/0x1d0 [async_memcpy]
Feb 26 13:51:35 shakti kernel: [89092.568129]  [<f88e6181>] ops_run_postxor+0xd1/0x160 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.568501]  [<f88e4e99>] async_copy_data+0x79/0x140 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.568920]  [<f88e69ec>] handle_stripe5+0x6fc/0x1590 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.569521]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.570010]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.570438]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:35 shakti kernel: [89092.570656]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.571185]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:51:35 shakti kernel: [89092.571409]  [<f88ab0c6>] md_wakeup_thread+0x26/0x30 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.571908]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.572255]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.572748]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:51:35 shakti kernel: [89092.573159]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.573679]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.574166]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.574660]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:51:35 shakti kernel: [89092.574884]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:35 shakti kernel: [89092.575368]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:51:35 shakti kernel: [89092.575525]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:51:35 shakti kernel: [89092.575691]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:51:35 shakti kernel: [89092.575905]  =======================
Feb 26 13:51:47 shakti kernel: [89104.360210] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:51:47 shakti kernel: [89104.360537]
Feb 26 13:51:47 shakti kernel: [89104.360639] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:51:47 shakti kernel: [89104.360767] EIP: 0060:[<f90f75ea>] EFLAGS: 00000287 CPU: 1
Feb 26 13:51:47 shakti kernel: [89104.360982] EIP is at ipt_do_table+0x12a/0x4b0 [ip_tables]
Feb 26 13:51:47 shakti kernel: [89104.361099] EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 0000000c
Feb 26 13:51:47 shakti kernel: [89104.361237] ESI: f90f99d4 EDI: f91e6094 EBP: f91e7300 ESP: df9cfa5c
Feb 26 13:51:47 shakti kernel: [89104.361359]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:51:47 shakti kernel: [89104.361499] CR0: 8005003b CR2: b64d4000 CR3: 00494000 CR4: 000006b0
Feb 26 13:51:47 shakti kernel: [89104.361599] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:51:47 shakti kernel: [89104.361693] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:51:47 shakti kernel: [89104.362050]  [<f90e6000>] ipt_route_hook+0x0/0x20 [iptable_mangle]
Feb 26 13:51:47 shakti kernel: [89104.362306]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 13:51:47 shakti kernel: [89104.362557]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 13:51:47 shakti kernel: [89104.362764]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:47 shakti kernel: [89104.363000]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:51:47 shakti kernel: [89104.363193]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:47 shakti kernel: [89104.363385]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:51:47 shakti kernel: [89104.363587]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:51:47 shakti kernel: [89104.363855]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 13:51:47 shakti kernel: [89104.364420]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 13:51:47 shakti kernel: [89104.364953]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 13:51:47 shakti kernel: [89104.365608]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 13:51:47 shakti kernel: [89104.366106]  [<c02c5dfc>] __qdisc_run+0x7c/0x1a0
Feb 26 13:51:47 shakti kernel: [89104.366307]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:51:47 shakti kernel: [89104.366569]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:47 shakti kernel: [89104.366800]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:51:47 shakti kernel: [89104.366983]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:51:47 shakti kernel: [89104.367139]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:51:47 shakti kernel: [89104.367330]  [<c0216eb3>] deadline_add_request+0x23/0x60
Feb 26 13:51:47 shakti kernel: [89104.367520]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:47 shakti kernel: [89104.367765]  [<c021007b>] blk_queue_invalidate_tags+0x2b/0x40
Feb 26 13:51:47 shakti kernel: [89104.367965]  [<c020007b>] security_netlbl_secattr_to_sid+0x23b/0x250
Feb 26 13:51:47 shakti kernel: [89104.368174]  [<c0212048>] __make_request+0xd8/0x5b0
Feb 26 13:51:47 shakti kernel: [89104.368414]  [<c014f3a8>] tick_program_event+0x38/0x60
Feb 26 13:51:47 shakti kernel: [89104.368668]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 13:51:47 shakti kernel: [89104.368894]  [<c020ed85>] generic_make_request+0x225/0x4c0
Feb 26 13:51:47 shakti kernel: [89104.369088]  [<c01498a0>] run_hrtimer_softirq+0xe0/0xf0
Feb 26 13:51:47 shakti kernel: [89104.369310]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:47 shakti kernel: [89104.369589]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:47 shakti kernel: [89104.369870]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Feb 26 13:51:47 shakti kernel: [89104.370222]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:51:47 shakti kernel: [89104.370507]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 13:51:47 shakti kernel: [89104.370689]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 13:51:47 shakti kernel: [89104.370855]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 13:51:47 shakti kernel: [89104.371179]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.371664]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:51:47 shakti kernel: [89104.372000]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 13:51:47 shakti kernel: [89104.372267]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:47 shakti kernel: [89104.372489]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.373015]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:51:47 shakti kernel: [89104.373255]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:51:47 shakti kernel: [89104.373600]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.374085]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:51:47 shakti kernel: [89104.374508]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.375025]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.375507]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.375994]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:51:47 shakti kernel: [89104.376225]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:47 shakti kernel: [89104.376703]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:51:47 shakti kernel: [89104.376857]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:51:47 shakti kernel: [89104.377027]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:51:47 shakti kernel: [89104.377249]  =======================
Feb 26 13:51:58 shakti kernel: [89116.169014] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:51:58 shakti kernel: [89116.169336]
Feb 26 13:51:58 shakti kernel: [89116.169438] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:51:58 shakti kernel: [89116.169568] EIP: 0060:[<c02ed6b0>] EFLAGS: 00000297 CPU: 1
Feb 26 13:51:58 shakti kernel: [89116.169698] EIP is at __tcp_push_pending_frames+0xf0/0x8f0
Feb 26 13:51:58 shakti kernel: [89116.169823] EAX: d545c000 EBX: e2133600 ECX: 00000b50 EDX: e2133600
Feb 26 13:51:58 shakti kernel: [89116.169972] ESI: d545c000 EDI: 00000019 EBP: e2133620 ESP: df9cfa48
Feb 26 13:51:58 shakti kernel: [89116.170100]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:51:58 shakti kernel: [89116.170223] CR0: 8005003b CR2: b64d4000 CR3: 00494000 CR4: 000006b0
Feb 26 13:51:58 shakti kernel: [89116.170323] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:51:58 shakti kernel: [89116.170418] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:51:58 shakti kernel: [89116.170763]  [<c02eb297>] tcp_current_mss+0x77/0x110
Feb 26 13:51:58 shakti kernel: [89116.170988]  [<c02ea984>] tcp_rcv_established+0x434/0x950
Feb 26 13:51:58 shakti kernel: [89116.171256]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Feb 26 13:51:58 shakti kernel: [89116.171449]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Feb 26 13:51:58 shakti kernel: [89116.171626]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Feb 26 13:51:58 shakti kernel: [89116.171922]  [<c02f1590>] tcp_v4_do_rcv+0x340/0x6e0
Feb 26 13:51:58 shakti kernel: [89116.172126]  [<c02d30c9>] ip_route_input+0x39/0xdf0
Feb 26 13:51:58 shakti kernel: [89116.172318]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 13:51:58 shakti kernel: [89116.173043]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:51:58 shakti kernel: [89116.173702]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:58 shakti kernel: [89116.174008]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Feb 26 13:51:58 shakti kernel: [89116.174327]  [<c02f417d>] tcp_v4_rcv+0x7bd/0x9a0
Feb 26 13:51:58 shakti kernel: [89116.174625]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 13:51:58 shakti kernel: [89116.174855]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 13:51:58 shakti kernel: [89116.175063]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:58 shakti kernel: [89116.175293]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:51:58 shakti kernel: [89116.175485]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:51:58 shakti kernel: [89116.175677]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:51:58 shakti kernel: [89116.175857]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:51:58 shakti kernel: [89116.176117]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 13:51:58 shakti kernel: [89116.176685]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 13:51:58 shakti kernel: [89116.177230]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 13:51:58 shakti kernel: [89116.177892]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 13:51:58 shakti kernel: [89116.178449]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:51:58 shakti kernel: [89116.178715]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:51:58 shakti kernel: [89116.178944]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:51:58 shakti kernel: [89116.179129]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:51:58 shakti kernel: [89116.179286]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:51:58 shakti kernel: [89116.179499]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:51:58 shakti kernel: [89116.179750]  [<c01b007b>] single_open+0xb/0x90
Feb 26 13:51:58 shakti kernel: [89116.179935]  [<f88800d8>] max_io_len+0x48/0xb0 [dm_mod]
Feb 26 13:51:58 shakti kernel: [89116.180416]  [<c0170cd5>] mempool_free+0x15/0xa0
Feb 26 13:51:58 shakti kernel: [89116.180629]  [<f88e302b>] return_io+0x2b/0x40 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.180961]  [<f88e6c52>] handle_stripe5+0x962/0x1590 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.181338]  [<c016a77b>] handle_edge_irq+0x7b/0x120
Feb 26 13:51:58 shakti kernel: [89116.181640]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 13:51:58 shakti kernel: [89116.181824]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 13:51:58 shakti kernel: [89116.181990]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 13:51:58 shakti kernel: [89116.182322]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.182816]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.183156]  [<c012a88e>] try_to_wake_up+0x4e/0x350
Feb 26 13:51:58 shakti kernel: [89116.183440]  [<c0126a7b>] __wake_up_common+0x4b/0x80
Feb 26 13:51:58 shakti kernel: [89116.183667]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:51:58 shakti kernel: [89116.183894]  [<f88e3ace>] __release_stripe+0x10e/0x150 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.184253]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.184595]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.185067]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:51:58 shakti kernel: [89116.185496]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.186025]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.186513]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.187008]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:51:58 shakti kernel: [89116.187241]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:51:58 shakti kernel: [89116.187728]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:51:58 shakti kernel: [89116.187904]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:51:58 shakti kernel: [89116.188073]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:51:58 shakti kernel: [89116.188300]  =======================
Feb 26 13:52:10 shakti kernel: [89127.967830] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 13:52:10 shakti kernel: [89127.968150]
Feb 26 13:52:10 shakti kernel: [89127.968252] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 13:52:10 shakti kernel: [89127.968387] EIP: 0060:[<f90f7670>] EFLAGS: 00000202 CPU: 1
Feb 26 13:52:10 shakti kernel: [89127.968602] EIP is at ipt_do_table+0x1b0/0x4b0 [ip_tables]
Feb 26 13:52:10 shakti kernel: [89127.968736] EAX: df9cf9e7 EBX: 0000009c ECX: 00000000 EDX: e251de40
Feb 26 13:52:10 shakti kernel: [89127.968866] ESI: f91e6edc EDI: f91e6e6c EBP: 00000070 ESP: df9cf970
Feb 26 13:52:10 shakti kernel: [89127.968984]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 13:52:10 shakti kernel: [89127.969125] CR0: 8005003b CR2: b64d4000 CR3: 00494000 CR4: 000006b0
Feb 26 13:52:10 shakti kernel: [89127.969227] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 13:52:10 shakti kernel: [89127.969330] DR6: ffff0ff0 DR7: 00000400
Feb 26 13:52:10 shakti kernel: [89127.969476]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Feb 26 13:52:10 shakti kernel: [89127.969943]  [<f90e6000>] ipt_route_hook+0x0/0x20 [iptable_mangle]
Feb 26 13:52:10 shakti kernel: [89127.970198]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 13:52:10 shakti kernel: [89127.970448]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 13:52:10 shakti kernel: [89127.970656]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Feb 26 13:52:10 shakti kernel: [89127.970897]  [<c02db31c>] ip_output+0x8c/0xa0
Feb 26 13:52:10 shakti kernel: [89127.971091]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Feb 26 13:52:10 shakti kernel: [89127.971299]  [<c02d8a2e>] ip_push_pending_frames+0x31e/0x410
Feb 26 13:52:10 shakti kernel: [89127.971519]  [<c02d85b0>] dst_output+0x0/0x10
Feb 26 13:52:10 shakti kernel: [89127.971758]  [<c02fc839>] icmp_send+0x289/0x410
Feb 26 13:52:10 shakti kernel: [89127.972039]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Feb 26 13:52:10 shakti kernel: [89127.972231]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Feb 26 13:52:10 shakti kernel: [89127.972503]  [<f917502d>] ctnetlink_conntrack_event+0x4d/0x930 [nf_conntrack_netlink]
Feb 26 13:52:10 shakti kernel: [89127.972905]  [<c02f7833>] __udp4_lib_lookup+0x23/0x120
Feb 26 13:52:10 shakti kernel: [89127.973140]  [<c02f88c7>] __udp4_lib_rcv+0x4e7/0x840
Feb 26 13:52:10 shakti kernel: [89127.973355]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Feb 26 13:52:10 shakti kernel: [89127.973995]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Feb 26 13:52:10 shakti kernel: [89127.974297]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Feb 26 13:52:10 shakti kernel: [89127.974582]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 13:52:10 shakti kernel: [89127.974749]  [<c02d5e60>] ip_local_deliver_finish+0x0/0x210
Feb 26 13:52:10 shakti kernel: [89127.974971]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 13:52:10 shakti kernel: [89127.975177]  [<c02d5e60>] ip_local_deliver_finish+0x0/0x210
Feb 26 13:52:10 shakti kernel: [89127.975407]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 13:52:10 shakti kernel: [89127.975635]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 13:52:10 shakti kernel: [89127.975844]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:52:10 shakti kernel: [89127.976066]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 13:52:10 shakti kernel: [89127.976257]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 13:52:10 shakti kernel: [89127.976447]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 13:52:10 shakti kernel: [89127.976622]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 13:52:10 shakti kernel: [89127.976874]  [<f8975dc9>] e100_poll+0x119/0x2f0 [e100]
Feb 26 13:52:10 shakti kernel: [89127.977228]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 13:52:10 shakti kernel: [89127.977393]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 13:52:10 shakti kernel: [89127.977562]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 13:52:10 shakti kernel: [89127.977751]  [<f8975d27>] e100_poll+0x77/0x2f0 [e100]
Feb 26 13:52:10 shakti kernel: [89127.978141]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 13:52:10 shakti kernel: [89127.978327]  [<c014f3a8>] tick_program_event+0x38/0x60
Feb 26 13:52:10 shakti kernel: [89127.978564]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:52:10 shakti kernel: [89127.978789]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 13:52:10 shakti kernel: [89127.978974]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 13:52:10 shakti kernel: [89127.979129]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 13:52:10 shakti kernel: [89127.979336]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 13:52:10 shakti kernel: [89127.979571]  [<c017007b>] generic_file_aio_write_nolock+0x7b/0xb0
Feb 26 13:52:10 shakti kernel: [89127.979775]  [<c017007b>] generic_file_aio_write_nolock+0x7b/0xb0
Feb 26 13:52:10 shakti kernel: [89127.979980]  [<f88804f2>] dec_pending+0xb2/0x1e0 [dm_mod]
Feb 26 13:52:10 shakti kernel: [89127.980482]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 13:52:10 shakti kernel: [89127.980675]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 13:52:10 shakti kernel: [89127.980907]  [<f88807e2>] clone_endio+0x62/0xb0 [dm_mod]
Feb 26 13:52:10 shakti kernel: [89127.981438]  [<f88e302b>] return_io+0x2b/0x40 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.981764]  [<f88e6c52>] handle_stripe5+0x962/0x1590 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.982223]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 13:52:10 shakti kernel: [89127.982406]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 13:52:10 shakti kernel: [89127.982572]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 13:52:10 shakti kernel: [89127.982855]  [<c021dd47>] rb_insert_color+0xb7/0xe0
Feb 26 13:52:10 shakti kernel: [89127.983063]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.983548]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.983967]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 13:52:10 shakti kernel: [89127.984185]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.984690]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 13:52:10 shakti kernel: [89127.984912]  [<f88e3ace>] __release_stripe+0x10e/0x150 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.985269]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.985611]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.986095]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 13:52:10 shakti kernel: [89127.986500]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.987005]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.987478]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.987957]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 13:52:10 shakti kernel: [89127.988176]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 13:52:10 shakti kernel: [89127.988650]  [<c0145c62>] kthread+0x42/0x70
Feb 26 13:52:10 shakti kernel: [89127.988802]  [<c0145c20>] kthread+0x0/0x70
Feb 26 13:52:10 shakti kernel: [89127.988968]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 13:52:10 shakti kernel: [89127.989182]  =======================

--Apple-Mail-6-1037319543
Content-Disposition: attachment;
	filename=oops2.txt
Content-Type: text/plain;
	x-unix-mode=0600;
	name="oops2.txt"
Content-Transfer-Encoding: 7bit

Feb 26 14:17:52 shakti kernel: [90667.792936] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 14:17:52 shakti kernel: [90667.793261]
Feb 26 14:17:52 shakti kernel: [90667.793362] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 14:17:52 shakti kernel: [90667.793495] EIP: 0060:[<f91140ae>] EFLAGS: 00000293 CPU: 1
Feb 26 14:17:52 shakti kernel: [90667.794055] EIP is at tcp_packet+0x5e/0xbb0 [nf_conntrack]
Feb 26 14:17:52 shakti kernel: [90667.794197] EAX: d8502634 EBX: f9114050 ECX: 00000014 EDX: e65d5480
Feb 26 14:17:52 shakti kernel: [90667.794316] ESI: d54c2a50 EDI: d54c2a50 EBP: 00000000 ESP: df9cf930
Feb 26 14:17:52 shakti kernel: [90667.794433]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 14:17:52 shakti kernel: [90667.794554] CR0: 80050033 CR2: b7bec04d CR3: 00494000 CR4: 000006b0
Feb 26 14:17:52 shakti kernel: [90667.794658] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 14:17:52 shakti kernel: [90667.794759] DR6: ffff0ff0 DR7: 00000400
Feb 26 14:17:52 shakti kernel: [90667.794880]  [<f9285e91>] svc_sock_enqueue+0x1e1/0x310 [sunrpc]
Feb 26 14:17:52 shakti kernel: [90667.796041]  [<f928719d>] svc_tcp_data_ready+0x2d/0x90 [sunrpc]
Feb 26 14:17:52 shakti kernel: [90667.797031]  [<c02eb297>] tcp_current_mss+0x77/0x110
Feb 26 14:17:52 shakti kernel: [90667.797248]  [<c02eac2d>] tcp_rcv_established+0x6dd/0x950
Feb 26 14:17:52 shakti kernel: [90667.797497]  [<c030d2c0>] nf_ip_checksum+0x0/0x120
Feb 26 14:17:52 shakti kernel: [90667.797778]  [<f91103fc>] __nf_conntrack_find+0x1c/0x110 [nf_conntrack]
Feb 26 14:17:52 shakti kernel: [90667.798423]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Feb 26 14:17:52 shakti kernel: [90667.799063]  [<f91117b1>] nf_conntrack_in+0x201/0x4d0 [nf_conntrack]
Feb 26 14:17:52 shakti kernel: [90667.799917]  [<f9102240>] ipv4_conntrack_in+0x0/0x10 [nf_conntrack_ipv4]
Feb 26 14:17:52 shakti kernel: [90667.800245]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 14:17:52 shakti kernel: [90667.800434]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:17:52 shakti kernel: [90667.800664]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 14:17:52 shakti kernel: [90667.800870]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:17:52 shakti kernel: [90667.801095]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 14:17:52 shakti kernel: [90667.801289]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:17:52 shakti kernel: [90667.801458]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 14:17:52 shakti kernel: [90667.801656]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 14:17:52 shakti kernel: [90667.801916]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 14:17:52 shakti kernel: [90667.802481]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 14:17:52 shakti kernel: [90667.803021]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 14:17:52 shakti kernel: [90667.803668]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 14:17:52 shakti kernel: [90667.804220]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 14:17:52 shakti kernel: [90667.804480]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:17:52 shakti kernel: [90667.804709]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 14:17:52 shakti kernel: [90667.804894]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 14:17:52 shakti kernel: [90667.805049]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 14:17:52 shakti kernel: [90667.805254]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 14:17:52 shakti kernel: [90667.805515]  [<f8899cce>] xor_sse_4+0x19e/0x360 [xor]
Feb 26 14:17:52 shakti kernel: [90667.805918]  [<f8898b15>] xor_blocks+0x75/0xa0 [xor]
Feb 26 14:17:52 shakti kernel: [90667.806205]  [<f88942fb>] async_xor+0x2fb/0x350 [async_xor]
Feb 26 14:17:52 shakti kernel: [90667.806527]  [<f88e5d50>] ops_complete_write+0x0/0x60 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.806897]  [<f88e6181>] ops_run_postxor+0xd1/0x160 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.807262]  [<f88e5d50>] ops_complete_write+0x0/0x60 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.807698]  [<f88e7330>] handle_stripe5+0x1040/0x1590 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.808267]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.808755]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.809094]  [<c0148c12>] enqueue_hrtimer+0x72/0x100
Feb 26 14:17:52 shakti kernel: [90667.809337]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:17:52 shakti kernel: [90667.809574]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 14:17:52 shakti kernel: [90667.809785]  [<f88e3ace>] __release_stripe+0x10e/0x150 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.810131]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.810464]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.810938]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 14:17:52 shakti kernel: [90667.811313]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 14:17:52 shakti kernel: [90667.811523]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.812036]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.812523]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.813014]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 14:17:52 shakti kernel: [90667.813238]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:17:52 shakti kernel: [90667.813722]  [<c0145c62>] kthread+0x42/0x70
Feb 26 14:17:52 shakti kernel: [90667.813875]  [<c0145c20>] kthread+0x0/0x70
Feb 26 14:17:52 shakti kernel: [90667.814039]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 14:17:52 shakti kernel: [90667.814252]  =======================
Feb 26 14:19:13 shakti kernel: [90748.930999] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 14:19:13 shakti kernel: [90748.931321]
Feb 26 14:19:13 shakti kernel: [90748.931421] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 14:19:13 shakti kernel: [90748.931551] EIP: 0060:[<c0136cc0>] EFLAGS: 00000212 CPU: 1
Feb 26 14:19:13 shakti kernel: [90748.931672] EIP is at local_bh_enable+0x20/0xa0
Feb 26 14:19:13 shakti kernel: [90748.931796] EAX: df9ce000 EBX: 00000008 ECX: c040d120 EDX: e11b9e40
Feb 26 14:19:13 shakti kernel: [90748.931943] ESI: d90fb300 EDI: e11b9e40 EBP: 00000000 ESP: df9cfa68
Feb 26 14:19:13 shakti kernel: [90748.932059]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 14:19:13 shakti kernel: [90748.932184] CR0: 8005003b CR2: b7a53000 CR3: 00494000 CR4: 000006b0
Feb 26 14:19:13 shakti kernel: [90748.932289] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 14:19:13 shakti kernel: [90748.932388] DR6: ffff0ff0 DR7: 00000400
Feb 26 14:19:13 shakti kernel: [90748.932514]  [<c01eba0c>] security_sock_rcv_skb+0xc/0x10
Feb 26 14:19:13 shakti kernel: [90748.932691]  [<c02f41b6>] tcp_v4_rcv+0x7f6/0x9a0
Feb 26 14:19:13 shakti kernel: [90748.933001]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Feb 26 14:19:13 shakti kernel: [90748.933243]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Feb 26 14:19:13 shakti kernel: [90748.933459]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:19:13 shakti kernel: [90748.933699]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 14:19:13 shakti kernel: [90748.933896]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:19:13 shakti kernel: [90748.934090]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 14:19:13 shakti kernel: [90748.934294]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 14:19:13 shakti kernel: [90748.934572]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 14:19:13 shakti kernel: [90748.935143]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 14:19:13 shakti kernel: [90748.935684]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 14:19:13 shakti kernel: [90748.936372]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 14:19:13 shakti kernel: [90748.936929]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 14:19:13 shakti kernel: [90748.937210]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:19:13 shakti kernel: [90748.937451]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 14:19:13 shakti kernel: [90748.937637]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 14:19:13 shakti kernel: [90748.937816]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 14:19:13 shakti kernel: [90748.937995]  [<c0217084>] deadline_dispatch_requests+0x44/0xd0
Feb 26 14:19:13 shakti kernel: [90748.938209]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 14:19:13 shakti kernel: [90748.938494]  [<f890b167>] scsi_request_fn+0x1d7/0x380 [scsi_mod]
Feb 26 14:19:13 shakti kernel: [90748.939343]  [<c020ce61>] elv_insert+0xd1/0x230
Feb 26 14:19:13 shakti kernel: [90748.939592]  [<c0210b85>] __generic_unplug_device+0x25/0x30
Feb 26 14:19:13 shakti kernel: [90748.939794]  [<c021202a>] __make_request+0xba/0x5b0
Feb 26 14:19:13 shakti kernel: [90748.940122]  [<c020ed85>] generic_make_request+0x225/0x4c0
Feb 26 14:19:13 shakti kernel: [90748.940319]  [<c012a88e>] try_to_wake_up+0x4e/0x350
Feb 26 14:19:13 shakti kernel: [90748.940651]  [<c010e7f3>] sched_clock+0x13/0x30
Feb 26 14:19:13 shakti kernel: [90748.940862]  [<c0127153>] update_curr+0x103/0x110
Feb 26 14:19:13 shakti kernel: [90748.941109]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Feb 26 14:19:13 shakti kernel: [90748.941450]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 14:19:13 shakti kernel: [90748.941756]  [<c014be14>] getnstimeofday+0x34/0xf0
Feb 26 14:19:13 shakti kernel: [90748.941940]  [<c011c27c>] lapic_next_event+0xc/0x10
Feb 26 14:19:13 shakti kernel: [90748.942107]  [<c014e283>] clockevents_program_event+0xa3/0x150
Feb 26 14:19:13 shakti kernel: [90748.942438]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.942924]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 14:19:13 shakti kernel: [90748.943355]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:19:13 shakti kernel: [90748.943574]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.944067]  [<c0136de1>] irq_exit+0x51/0x80
Feb 26 14:19:13 shakti kernel: [90748.944244]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 14:19:13 shakti kernel: [90748.944449]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 14:19:13 shakti kernel: [90748.944675]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.945178]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Feb 26 14:19:13 shakti kernel: [90748.945524]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.945989]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 14:19:13 shakti kernel: [90748.946379]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 14:19:13 shakti kernel: [90748.946594]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.947076]  [<c014007b>] sys_setsid+0x2b/0xf0
Feb 26 14:19:13 shakti kernel: [90748.947262]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.947744]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.948230]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 14:19:13 shakti kernel: [90748.948440]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:13 shakti kernel: [90748.948916]  [<c0145c62>] kthread+0x42/0x70
Feb 26 14:19:13 shakti kernel: [90748.949071]  [<c0145c20>] kthread+0x0/0x70
Feb 26 14:19:13 shakti kernel: [90748.949239]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 14:19:13 shakti kernel: [90748.949459]  =======================
Feb 26 14:19:25 shakti kernel: [90760.730510] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Feb 26 14:19:25 shakti kernel: [90760.730841]
Feb 26 14:19:25 shakti kernel: [90760.730942] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Feb 26 14:19:25 shakti kernel: [90760.731070] EIP: 0060:[<f90fb55e>] EFLAGS: 00000296 CPU: 1
Feb 26 14:19:25 shakti kernel: [90760.731253] EIP is at nf_nat_in+0x1e/0xb0 [iptable_nat]
Feb 26 14:19:25 shakti kernel: [90760.731391] EAX: 00000000 EBX: 0101a8c0 ECX: f6550000 EDX: c02d5af0
Feb 26 14:19:25 shakti kernel: [90760.731521] ESI: df9cfadc EDI: d4020d80 EBP: 80000000 ESP: df9cfa84
Feb 26 14:19:25 shakti kernel: [90760.731641]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 14:19:25 shakti kernel: [90760.731765] CR0: 8005003b CR2: b7a53000 CR3: 00494000 CR4: 000006b0
Feb 26 14:19:25 shakti kernel: [90760.731868] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 14:19:25 shakti kernel: [90760.731964] DR6: ffff0ff0 DR7: 00000400
Feb 26 14:19:25 shakti kernel: [90760.732087]  [<f90e6000>] ipt_route_hook+0x0/0x20 [iptable_mangle]
Feb 26 14:19:25 shakti kernel: [90760.732300]  [<f90fb540>] nf_nat_in+0x0/0xb0 [iptable_nat]
Feb 26 14:19:25 shakti kernel: [90760.732535]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 14:19:25 shakti kernel: [90760.732726]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:19:25 shakti kernel: [90760.732966]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 14:19:25 shakti kernel: [90760.733176]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:19:25 shakti kernel: [90760.733414]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 14:19:25 shakti kernel: [90760.733610]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 14:19:25 shakti kernel: [90760.733803]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 14:19:25 shakti kernel: [90760.734008]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 14:19:25 shakti kernel: [90760.734281]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 14:19:25 shakti kernel: [90760.734851]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 14:19:25 shakti kernel: [90760.735389]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 14:19:25 shakti kernel: [90760.736077]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 14:19:25 shakti kernel: [90760.736633]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 14:19:25 shakti kernel: [90760.736904]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:19:25 shakti kernel: [90760.737141]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 14:19:25 shakti kernel: [90760.737326]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 14:19:25 shakti kernel: [90760.737502]  [<c010a940>] do_IRQ+0x40/0x70
Feb 26 14:19:25 shakti kernel: [90760.737653]  [<c020d2ec>] elv_dispatch_add_tail+0x1c/0x60
Feb 26 14:19:25 shakti kernel: [90760.737872]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 14:19:25 shakti kernel: [90760.738139]  [<f890b167>] scsi_request_fn+0x1d7/0x380 [scsi_mod]
Feb 26 14:19:25 shakti kernel: [90760.738997]  [<c020ce61>] elv_insert+0xd1/0x230
Feb 26 14:19:25 shakti kernel: [90760.739223]  [<c0210b85>] __generic_unplug_device+0x25/0x30
Feb 26 14:19:25 shakti kernel: [90760.739427]  [<c021202a>] __make_request+0xba/0x5b0
Feb 26 14:19:25 shakti kernel: [90760.739622]  [<c0136de1>] irq_exit+0x51/0x80
Feb 26 14:19:25 shakti kernel: [90760.739776]  [<c010a940>] do_IRQ+0x40/0x70
Feb 26 14:19:25 shakti kernel: [90760.739945]  [<f8974fa0>] e100_xmit_frame+0x30/0x110 [e100]
Feb 26 14:19:25 shakti kernel: [90760.740325]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 14:19:25 shakti kernel: [90760.740585]  [<c020ed85>] generic_make_request+0x225/0x4c0
Feb 26 14:19:25 shakti kernel: [90760.740779]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 14:19:25 shakti kernel: [90760.740972]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 14:19:25 shakti kernel: [90760.741154]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 14:19:25 shakti kernel: [90760.741324]  [<c0170d48>] mempool_free+0x88/0xa0
Feb 26 14:19:25 shakti kernel: [90760.741585]  [<c0128cbe>] __wake_up+0x3e/0x60
Feb 26 14:19:25 shakti kernel: [90760.741814]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Feb 26 14:19:25 shakti kernel: [90760.742152]  [<c02adca8>] __kfree_skb+0x8/0x80
Feb 26 14:19:25 shakti kernel: [90760.742550]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.743025]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Feb 26 14:19:25 shakti kernel: [90760.743437]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 14:19:25 shakti kernel: [90760.743646]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.744130]  [<c0136de1>] irq_exit+0x51/0x80
Feb 26 14:19:25 shakti kernel: [90760.744305]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Feb 26 14:19:25 shakti kernel: [90760.744508]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Feb 26 14:19:25 shakti kernel: [90760.744728]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.745239]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.745717]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Feb 26 14:19:25 shakti kernel: [90760.746099]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 14:19:25 shakti kernel: [90760.746311]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.746793]  [<c014007b>] sys_setsid+0x2b/0xf0
Feb 26 14:19:25 shakti kernel: [90760.746992]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.747471]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.747954]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 14:19:25 shakti kernel: [90760.748173]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Feb 26 14:19:25 shakti kernel: [90760.748646]  [<c0145c62>] kthread+0x42/0x70
Feb 26 14:19:25 shakti kernel: [90760.748798]  [<c0145c20>] kthread+0x0/0x70
Feb 26 14:19:25 shakti kernel: [90760.748963]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 14:19:25 shakti kernel: [90760.749177]  =======================

--Apple-Mail-6-1037319543
Content-Disposition: attachment;
	filename=oops3.txt
Content-Type: text/plain;
	x-unix-mode=0600;
	name="oops3.txt"
Content-Transfer-Encoding: 7bit

Feb 26 18:59:44 shakti kernel: [107564.260936] BUG: soft lockup - CPU#0 stuck for 11s! [pdflush:8283]
Feb 26 18:59:44 shakti kernel: [107564.261258]
Feb 26 18:59:44 shakti kernel: [107564.261341] Pid: 8283, comm: pdflush Not tainted (2.6.24-8-server #1)
Feb 26 18:59:44 shakti kernel: [107564.261460] EIP: 0060:[<f90f77bf>] EFLAGS: 00000202 CPU: 0
Feb 26 18:59:44 shakti kernel: [107564.261659] EIP is at ipt_do_table+0x2ff/0x4b0 [ip_tables]
Feb 26 18:59:44 shakti kernel: [107564.261780] EAX: f91e3094 EBX: 00000000 ECX: 00000094 EDX: f91e4070
Feb 26 18:59:44 shakti kernel: [107564.261914] ESI: f91e3000 EDI: f91e3000 EBP: f91e3070 ESP: dfdf5958
Feb 26 18:59:44 shakti kernel: [107564.262035]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Feb 26 18:59:44 shakti kernel: [107564.262160] CR0: 8005003b CR2: b60cd000 CR3: 32d1f000 CR4: 000006f0
Feb 26 18:59:44 shakti kernel: [107564.262268] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 26 18:59:44 shakti kernel: [107564.262368] DR6: ffff0ff0 DR7: 00000400
Feb 26 18:59:44 shakti kernel: [107564.262725]  [<f90e6000>] ipt_route_hook+0x0/0x20 [iptable_mangle]
Feb 26 18:59:44 shakti kernel: [107564.262945]  [<c02cfa97>] nf_iterate+0x57/0x80
Feb 26 18:59:44 shakti kernel: [107564.263161]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Feb 26 18:59:44 shakti kernel: [107564.263336]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 18:59:44 shakti kernel: [107564.263554]  [<c02d632a>] ip_rcv+0x1ca/0x290
Feb 26 18:59:44 shakti kernel: [107564.263725]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Feb 26 18:59:44 shakti kernel: [107564.263889]  [<c02d6160>] ip_rcv+0x0/0x290
Feb 26 18:59:44 shakti kernel: [107564.264052]  [<c02b3839>] netif_receive_skb+0x379/0x440
Feb 26 18:59:44 shakti kernel: [107564.264289]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Feb 26 18:59:44 shakti kernel: [107564.264850]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Feb 26 18:59:44 shakti kernel: [107564.265391]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Feb 26 18:59:44 shakti kernel: [107564.266084]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Feb 26 18:59:44 shakti kernel: [107564.266644]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Feb 26 18:59:44 shakti kernel: [107564.266919]  [<c0136a32>] __do_softirq+0x82/0x110
Feb 26 18:59:44 shakti kernel: [107564.267160]  [<c0136b15>] do_softirq+0x55/0x60
Feb 26 18:59:44 shakti kernel: [107564.267348]  [<c0136dfd>] irq_exit+0x6d/0x80
Feb 26 18:59:44 shakti kernel: [107564.267505]  [<c010a940>] do_IRQ+0x40/0x70
Feb 26 18:59:44 shakti kernel: [107564.267687]  [<f8880706>] __map_bio+0xe6/0x160 [dm_mod]
Feb 26 18:59:44 shakti kernel: [107564.268201]  [<c0108dff>] common_interrupt+0x23/0x28
Feb 26 18:59:44 shakti kernel: [107564.268466]  [<c032aadd>] _spin_unlock_irqrestore+0xd/0x20
Feb 26 18:59:44 shakti kernel: [107564.268683]  [<f88ea945>] make_request+0x285/0x730 [raid456]
Feb 26 18:59:44 shakti kernel: [107564.269169]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Feb 26 18:59:44 shakti kernel: [107564.269406]  [<f8881819>] dm_request+0xd9/0x120 [dm_mod]
Feb 26 18:59:44 shakti kernel: [107564.269920]  [<c020ed85>] generic_make_request+0x225/0x4c0
Feb 26 18:59:44 shakti kernel: [107564.270142]  [<c0136de1>] irq_exit+0x51/0x80
Feb 26 18:59:44 shakti kernel: [107564.270320]  [<c010a940>] do_IRQ+0x40/0x70
Feb 26 18:59:44 shakti kernel: [107564.270543]  [<c01916fe>] __slab_alloc+0x2ee/0x4a0
Feb 26 18:59:44 shakti kernel: [107564.270799]  [<c0170d8d>] mempool_alloc+0x2d/0xe0
Feb 26 18:59:44 shakti kernel: [107564.271046]  [<c020f08b>] submit_bio+0x6b/0x100
Feb 26 18:59:44 shakti kernel: [107564.271267]  [<c01ba7a1>] bio_alloc_bioset+0x81/0x150
Feb 26 18:59:44 shakti kernel: [107564.271541]  [<f8adb15b>] xfs_submit_ioend_bio+0x1b/0x30 [xfs]
Feb 26 18:59:44 shakti kernel: [107564.272906]  [<f8adb241>] xfs_submit_ioend+0xb1/0xf0 [xfs]
Feb 26 18:59:44 shakti kernel: [107564.274294]  [<f8adc258>] xfs_page_state_convert+0x1f8/0x7f0 [xfs]
Feb 26 18:59:44 shakti kernel: [107564.275885]  [<f8adc981>] xfs_vm_writepage+0x61/0xf0 [xfs]
Feb 26 18:59:44 shakti kernel: [107564.277274]  [<c01742b8>] __writepage+0x8/0x30
Feb 26 18:59:44 shakti kernel: [107564.277462]  [<c01748af>] write_cache_pages+0x20f/0x300
Feb 26 18:59:44 shakti kernel: [107564.277649]  [<c01742b0>] __writepage+0x0/0x30
Feb 26 18:59:44 shakti kernel: [107564.277841]  [<c01742b0>] __writepage+0x0/0x30
Feb 26 18:59:44 shakti kernel: [107564.278159]  [<c01749c0>] generic_writepages+0x20/0x30
Feb 26 18:59:44 shakti kernel: [107564.278357]  [<c01749fb>] do_writepages+0x2b/0x50
Feb 26 18:59:44 shakti kernel: [107564.278552]  [<c01b27d9>] __writeback_single_inode+0x89/0x310
Feb 26 18:59:44 shakti kernel: [107564.278804]  [<f88832a1>] dm_table_any_congested+0x21/0x60 [dm_mod]
Feb 26 18:59:44 shakti kernel: [107564.279341]  [<c01b2dff>] sync_sb_inodes+0x19f/0x270
Feb 26 18:59:44 shakti kernel: [107564.279575]  [<c01b30e9>] writeback_inodes+0x89/0xc0
Feb 26 18:59:44 shakti kernel: [107564.279785]  [<c01752d4>] background_writeout+0x94/0xb0
Feb 26 18:59:44 shakti kernel: [107564.280052]  [<c0175850>] pdflush+0x0/0x1f0
Feb 26 18:59:44 shakti kernel: [107564.280232]  [<c0175974>] pdflush+0x124/0x1f0
Feb 26 18:59:44 shakti kernel: [107564.280404]  [<c0175240>] background_writeout+0x0/0xb0
Feb 26 18:59:44 shakti kernel: [107564.280609]  [<c0145c62>] kthread+0x42/0x70
Feb 26 18:59:44 shakti kernel: [107564.280784]  [<c0145c20>] kthread+0x0/0x70
Feb 26 18:59:44 shakti kernel: [107564.280952]  [<c010900b>] kernel_thread_helper+0x7/0x10
Feb 26 18:59:44 shakti kernel: [107564.281170]  =======================

--Apple-Mail-6-1037319543
Content-Disposition: attachment;
	filename=oops4.txt
Content-Type: text/plain;
	x-unix-mode=0600;
	name="oops4.txt"
Content-Transfer-Encoding: 7bit

Mar  5 09:45:54 shakti kernel: [764912.385931] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Mar  5 09:45:54 shakti kernel: [764912.386329]
Mar  5 09:45:54 shakti kernel: [764912.386425] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Mar  5 09:45:54 shakti kernel: [764912.386558] EIP: 0060:[<c0191a99>] EFLAGS: 00000296 CPU: 1
Mar  5 09:45:54 shakti kernel: [764912.386693] EIP is at kmem_cache_alloc+0x19/0xc0
Mar  5 09:45:54 shakti kernel: [764912.386820] EAX: c042d020 EBX: 00000020 ECX: 00000000 EDX: c02ae614
Mar  5 09:45:54 shakti kernel: [764912.386959] ESI: 00000100 EDI: 00000020 EBP: c042d020 ESP: df9cfc44
Mar  5 09:45:54 shakti kernel: [764912.387093]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Mar  5 09:45:54 shakti kernel: [764912.387233] CR0: 8005003b CR2: 084f0d4c CR3: 0506b000 CR4: 000006b0
Mar  5 09:45:54 shakti kernel: [764912.387353] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Mar  5 09:45:54 shakti kernel: [764912.387465] DR6: ffff0ff0 DR7: 00000400
Mar  5 09:45:54 shakti kernel: [764912.387586]  [<c02b3839>] netif_receive_skb+0x379/0x440
Mar  5 09:45:54 shakti kernel: [764912.387816]  [<c02ae614>] __alloc_skb+0x34/0x120
Mar  5 09:45:54 shakti kernel: [764912.388032]  [<c02af242>] __netdev_alloc_skb+0x22/0x50
Mar  5 09:45:54 shakti kernel: [764912.388248]  [<f8b0f38e>] e1000_clean_rx_irq+0x24e/0x300 [e1000e]
Mar  5 09:45:54 shakti kernel: [764912.388810]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Mar  5 09:45:54 shakti kernel: [764912.389536]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Mar  5 09:45:54 shakti kernel: [764912.390117]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Mar  5 09:45:54 shakti kernel: [764912.390396]  [<c0136a32>] __do_softirq+0x82/0x110
Mar  5 09:45:54 shakti kernel: [764912.390627]  [<c0136b15>] do_softirq+0x55/0x60
Mar  5 09:45:54 shakti kernel: [764912.390797]  [<c0136dfd>] irq_exit+0x6d/0x80
Mar  5 09:45:54 shakti kernel: [764912.390952]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Mar  5 09:45:54 shakti kernel: [764912.391174]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Mar  5 09:45:54 shakti kernel: [764912.391450]  [<c020eb9c>] generic_make_request+0x3c/0x4c0
Mar  5 09:45:54 shakti kernel: [764912.391686]  [<f88e6be0>] handle_stripe5+0x8f0/0x1590 [raid456]
Mar  5 09:45:54 shakti kernel: [764912.392448]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.392957]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Mar  5 09:45:54 shakti kernel: [764912.393440]  [<c0136a32>] __do_softirq+0x82/0x110
Mar  5 09:45:54 shakti kernel: [764912.393660]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.394218]  [<c0128cbe>] __wake_up+0x3e/0x60
Mar  5 09:45:54 shakti kernel: [764912.394457]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Mar  5 09:45:54 shakti kernel: [764912.394796]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.395285]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Mar  5 09:45:54 shakti kernel: [764912.395722]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.396215]  [<c014007b>] sys_setsid+0x2b/0xf0
Mar  5 09:45:54 shakti kernel: [764912.396407]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.396903]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.397406]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Mar  5 09:45:54 shakti kernel: [764912.397627]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:45:54 shakti kernel: [764912.398117]  [<c0145c62>] kthread+0x42/0x70
Mar  5 09:45:54 shakti kernel: [764912.398271]  [<c0145c20>] kthread+0x0/0x70
Mar  5 09:45:54 shakti kernel: [764912.398444]  [<c010900b>] kernel_thread_helper+0x7/0x10
Mar  5 09:45:54 shakti kernel: [764912.398659]  =======================
Mar  5 09:49:20 shakti kernel: [765117.901534] BUG: soft lockup - CPU#1 stuck for 11s! [md0_raid5:2768]
Mar  5 09:49:20 shakti kernel: [765117.901867]
Mar  5 09:49:20 shakti kernel: [765117.901955] Pid: 2768, comm: md0_raid5 Not tainted (2.6.24-8-server #1)
Mar  5 09:49:20 shakti kernel: [765117.902077] EIP: 0060:[<f9175086>] EFLAGS: 00000246 CPU: 1
Mar  5 09:49:20 shakti kernel: [765117.902298] EIP is at ctnetlink_conntrack_event+0xa6/0x930 [nf_conntrack_netlink]
Mar  5 09:49:20 shakti kernel: [765117.902429] EAX: 00000000 EBX: f9177ab8 ECX: eec59a50 EDX: 00000040
Mar  5 09:49:20 shakti kernel: [765117.902551] ESI: ffffffff EDI: 00000000 EBP: 00000000 ESP: df9cf900
Mar  5 09:49:20 shakti kernel: [765117.902672]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Mar  5 09:49:20 shakti kernel: [765117.902798] CR0: 8005003b CR2: b7e66000 CR3: 00494000 CR4: 000006b0
Mar  5 09:49:20 shakti kernel: [765117.902905] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Mar  5 09:49:20 shakti kernel: [765117.903006] DR6: ffff0ff0 DR7: 00000400
Mar  5 09:49:20 shakti kernel: [765117.903116]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Mar  5 09:49:20 shakti kernel: [765117.903391]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Mar  5 09:49:20 shakti kernel: [765117.903721]  [<c032ced0>] notifier_call_chain+0x30/0x60
Mar  5 09:49:20 shakti kernel: [765117.903931]  [<c032cf27>] atomic_notifier_call_chain+0x17/0x20
Mar  5 09:49:20 shakti kernel: [765117.904118]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Mar  5 09:49:20 shakti kernel: [765117.904729]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Mar  5 09:49:20 shakti kernel: [765117.904994]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Mar  5 09:49:20 shakti kernel: [765117.905261]  [<c02cfa97>] nf_iterate+0x57/0x80
Mar  5 09:49:20 shakti kernel: [765117.905415]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Mar  5 09:49:20 shakti kernel: [765117.905622]  [<c02cfb98>] nf_hook_slow+0x98/0xd0
Mar  5 09:49:20 shakti kernel: [765117.905795]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Mar  5 09:49:20 shakti kernel: [765117.906001]  [<c02db31c>] ip_output+0x8c/0xa0
Mar  5 09:49:20 shakti kernel: [765117.906163]  [<c02d9eb0>] ip_finish_output+0x0/0x2c0
Mar  5 09:49:20 shakti kernel: [765117.906335]  [<c02daedf>] ip_queue_xmit+0x27f/0x430
Mar  5 09:49:20 shakti kernel: [765117.906504]  [<c02d85b0>] dst_output+0x0/0x10
Mar  5 09:49:20 shakti kernel: [765117.906716]  [<c010e7f3>] sched_clock+0x13/0x30
Mar  5 09:49:20 shakti kernel: [765117.906915]  [<c0126a7b>] __wake_up_common+0x4b/0x80
Mar  5 09:49:20 shakti kernel: [765117.907095]  [<c032abc8>] _write_lock_bh+0x8/0x20
Mar  5 09:49:20 shakti kernel: [765117.907262]  [<c02f2384>] tcp_v4_send_check+0x44/0xf0
Mar  5 09:49:20 shakti kernel: [765117.907470]  [<c02ebc67>] tcp_transmit_skb+0x497/0x820
Mar  5 09:49:20 shakti kernel: [765117.907702]  [<c02ec0cb>] tcp_send_ack+0x2b/0x100
Mar  5 09:49:20 shakti kernel: [765117.907892]  [<c02ae635>] __alloc_skb+0x55/0x120
Mar  5 09:49:20 shakti kernel: [765117.908082]  [<c02ec156>] tcp_send_ack+0xb6/0x100
Mar  5 09:49:20 shakti kernel: [765117.908256]  [<c02eab1c>] tcp_rcv_established+0x5cc/0x950
Mar  5 09:49:20 shakti kernel: [765117.908491]  [<c0315510>] __xfrm_policy_check+0x3e0/0x570
Mar  5 09:49:20 shakti kernel: [765117.908650]  [<c0314f10>] xfrm_policy_lookup+0x0/0x220
Mar  5 09:49:20 shakti kernel: [765117.908809]  [<f90f76cb>] ipt_do_table+0x20b/0x4b0 [ip_tables]
Mar  5 09:49:20 shakti kernel: [765117.909085]  [<c02f1590>] tcp_v4_do_rcv+0x340/0x6e0
Mar  5 09:49:20 shakti kernel: [765117.909255]  [<c02d30c9>] ip_route_input+0x39/0xdf0
Mar  5 09:49:20 shakti kernel: [765117.909411]  [<f9114050>] tcp_packet+0x0/0xbb0 [nf_conntrack]
Mar  5 09:49:20 shakti kernel: [765117.910123]  [<f911550d>] nf_ct_deliver_cached_events+0x8d/0xc0 [nf_conntrack]
Mar  5 09:49:20 shakti kernel: [765117.910738]  [<f91021a9>] ipv4_confirm+0x29/0x50 [nf_conntrack_ipv4]
Mar  5 09:49:20 shakti kernel: [765117.911007]  [<f9102180>] ipv4_confirm+0x0/0x50 [nf_conntrack_ipv4]
Mar  5 09:49:20 shakti kernel: [765117.911311]  [<c02f417d>] tcp_v4_rcv+0x7bd/0x9a0
Mar  5 09:49:20 shakti kernel: [765117.911593]  [<c02d5f59>] ip_local_deliver_finish+0xf9/0x210
Mar  5 09:49:20 shakti kernel: [765117.911792]  [<c02d5bef>] ip_rcv_finish+0xff/0x370
Mar  5 09:49:20 shakti kernel: [765117.911969]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Mar  5 09:49:20 shakti kernel: [765117.912169]  [<c02d632a>] ip_rcv+0x1ca/0x290
Mar  5 09:49:20 shakti kernel: [765117.912329]  [<c02d5af0>] ip_rcv_finish+0x0/0x370
Mar  5 09:49:20 shakti kernel: [765117.912487]  [<c02d6160>] ip_rcv+0x0/0x290
Mar  5 09:49:20 shakti kernel: [765117.912653]  [<c02b3839>] netif_receive_skb+0x379/0x440
Mar  5 09:49:20 shakti kernel: [765117.912892]  [<f8b0bd17>] e1000_receive_skb+0x47/0x1a0 [e1000e]
Mar  5 09:49:20 shakti kernel: [765117.913425]  [<f8b0f264>] e1000_clean_rx_irq+0x124/0x300 [e1000e]
Mar  5 09:49:20 shakti kernel: [765117.913931]  [<f8b0f1b9>] e1000_clean_rx_irq+0x79/0x300 [e1000e]
Mar  5 09:49:20 shakti kernel: [765117.914525]  [<c014f3a8>] tick_program_event+0x38/0x60
Mar  5 09:49:20 shakti kernel: [765117.914738]  [<f8b0aca4>] e1000_clean+0x54/0x220 [e1000e]
Mar  5 09:49:20 shakti kernel: [765117.915303]  [<c02b5c2d>] net_rx_action+0x12d/0x210
Mar  5 09:49:20 shakti kernel: [765117.915549]  [<c0136a32>] __do_softirq+0x82/0x110
Mar  5 09:49:20 shakti kernel: [765117.915753]  [<c0136b15>] do_softirq+0x55/0x60
Mar  5 09:49:20 shakti kernel: [765117.915908]  [<c0136dfd>] irq_exit+0x6d/0x80
Mar  5 09:49:20 shakti kernel: [765117.916049]  [<c011c825>] smp_apic_timer_interrupt+0x55/0x80
Mar  5 09:49:20 shakti kernel: [765117.916249]  [<c0108ebc>] apic_timer_interrupt+0x28/0x30
Mar  5 09:49:20 shakti kernel: [765117.916501]  [<f88e6324>] handle_stripe5+0x34/0x1590 [raid456]
Mar  5 09:49:20 shakti kernel: [765117.917132]  [<c0127857>] enqueue_task_fair+0x27/0x30
Mar  5 09:49:20 shakti kernel: [765117.917323]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.917794]  [<f88e88b8>] handle_stripe+0x28/0xf00 [raid456]
Mar  5 09:49:20 shakti kernel: [765117.918110]  [<c012a88e>] try_to_wake_up+0x4e/0x350
Mar  5 09:49:20 shakti kernel: [765117.918391]  [<c0126a7b>] __wake_up_common+0x4b/0x80
Mar  5 09:49:20 shakti kernel: [765117.918621]  [<c0128cbe>] __wake_up+0x3e/0x60
Mar  5 09:49:20 shakti kernel: [765117.918850]  [<f88e3ace>] __release_stripe+0x10e/0x150 [raid456]
Mar  5 09:49:20 shakti kernel: [765117.919212]  [<f88e3b3f>] release_stripe+0x2f/0x50 [raid456]
Mar  5 09:49:20 shakti kernel: [765117.919555]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.920041]  [<f88e9b65>] raid5d+0x3d5/0x460 [raid456]
Mar  5 09:49:20 shakti kernel: [765117.920456]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.920947]  [<f88b007b>] md_do_sync+0x17b/0xb90 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.921458]  [<c0145fcc>] finish_wait+0xc/0x70
Mar  5 09:49:20 shakti kernel: [765117.921670]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.922157]  [<f88b2ec3>] md_thread+0x23/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.922648]  [<c0145f20>] autoremove_wake_function+0x0/0x40
Mar  5 09:49:20 shakti kernel: [765117.922882]  [<f88b2ea0>] md_thread+0x0/0xe0 [md_mod]
Mar  5 09:49:20 shakti kernel: [765117.923362]  [<c0145c62>] kthread+0x42/0x70
Mar  5 09:49:20 shakti kernel: [765117.923520]  [<c0145c20>] kthread+0x0/0x70
Mar  5 09:49:20 shakti kernel: [765117.923693]  [<c010900b>] kernel_thread_helper+0x7/0x10
Mar  5 09:49:20 shakti kernel: [765117.923898]  =======================

--Apple-Mail-6-1037319543
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7bit



--Apple-Mail-6-1037319543--
