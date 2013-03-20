From: Joerg Mayer <jmayer@loplof.de>
Subject: BUG: ipheth - NETDEV WATCHDOG: eth1 (ipheth): transmit queue 0
 timed out
Date: Thu, 21 Mar 2013 00:24:58 +0100
Message-ID: <20130320232458.GH4743@rhrk.uni-kl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

ipheth does not work for me at all with iPhone5 and iOS 6.

Setup:
Thinkpad T60 (32 bit) with openSUSE 12.1 (with current kernel repo)
iPhone5 with iOS 6.1.2
USB-Cable between laptop and iphone

In the moment I enable Hotspot with USB-cable connected to phone and
laptop, I get the following message:

--------------------------------------------------------
[Wed Mar 20 04:51:24 2013] usb 1-2: new high-speed USB device number 4 =
using ehci-pci
[Wed Mar 20 04:51:24 2013] usb 1-2: New USB device found, idVendor=3D05=
ac, idProduct=3D12a8
[Wed Mar 20 04:51:24 2013] usb 1-2: New USB device strings: Mfr=3D1, Pr=
oduct=3D2, SerialNumber=3D3
[Wed Mar 20 04:51:24 2013] usb 1-2: Product: iPhone
[Wed Mar 20 04:51:24 2013] usb 1-2: Manufacturer: Apple Inc.
[Wed Mar 20 04:51:24 2013] usb 1-2: SerialNumber: XXX
[Wed Mar 20 04:51:24 2013] ipheth 1-2:4.2: Apple iPhone USB Ethernet de=
vice attached
[Wed Mar 20 04:51:24 2013] usbcore: registered new interface driver iph=
eth
[Wed Mar 20 04:52:46 2013] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not=
 ready
[Wed Mar 20 04:55:28 2013] IPv6: ADDRCONF(NETDEV_CHANGE): eth1: link be=
comes ready
[Wed Mar 20 04:55:33 2013] ------------[ cut here ]------------
[Wed Mar 20 04:55:33 2013] WARNING: at /home/abuild/rpmbuild/BUILD/kern=
el-desktop-3.8.3/linux-3.8/net/sched/sch_generic.c:254 dev_watchdog+0x1=
e0/0x1f0()
[Wed Mar 20 04:55:33 2013] Hardware name: 200763G
[Wed Mar 20 04:55:33 2013] NETDEV WATCHDOG: eth1 (ipheth): transmit que=
ue 0 timed out
[Wed Mar 20 04:55:33 2013] Modules linked in: ipheth md4 md5 nls_utf8 c=
ifs fscache ppdev parport_pc lp parport af_packet rfcomm bnep binfmt_mi=
sc tp_smapi(OF) thinkpad_ec(OF) cpufreq_conservative cpufreq_userspace =
cpufreq_powersave sha256_generic cbc dm_crypt dm_mod snd_hda_codec_anal=
og snd_hda_intel btusb snd_hda_codec bluetooth acpi_cpufreq arc4 pcmcia=
 iwl3945 mperf iwlegacy coretemp snd_hwdep snd_pcm mac80211 kvm_intel i=
TCO_wdt iTCO_vendor_support snd_timer kvm sg lpc_ich snd_page_alloc mfd=
_core yenta_socket cfg80211 thinkpad_acpi pcmcia_rsrc pcmcia_core sr_mo=
d cdrom i2c_i801 rfkill snd joydev irda tpm_tis e1000e tpm tpm_bios crc=
_ccitt microcode video battery soundcore ac button autofs4 radeon ttm d=
rm_kms_helper drm i2c_algo_bit scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua s=
csi_dh_rdac scsi_dh edd fan ata_generic ata_piix thermal processor ther=
mal_sys
[Wed Mar 20 04:55:33 2013] Pid: 0, comm: swapper/0 Tainted: GF         =
 O 3.8.3-1-desktop #1
[Wed Mar 20 04:55:33 2013] Call Trace:
[Wed Mar 20 04:55:33 2013]  [<c0205709>] try_stack_unwind+0x199/0x1b0
[Wed Mar 20 04:55:33 2013]  [<c0204417>] dump_trace+0x47/0xf0
[Wed Mar 20 04:55:33 2013]  [<c020576b>] show_trace_log_lvl+0x4b/0x60
[Wed Mar 20 04:55:33 2013]  [<c0205798>] show_trace+0x18/0x20
[Wed Mar 20 04:55:33 2013]  [<c071a6cb>] dump_stack+0x6d/0x72
[Wed Mar 20 04:55:33 2013]  [<c02391c8>] warn_slowpath_common+0x78/0xb0
[Wed Mar 20 04:55:33 2013]  [<c0239293>] warn_slowpath_fmt+0x33/0x40
[Wed Mar 20 04:55:33 2013]  [<c0666350>] dev_watchdog+0x1e0/0x1f0
[Wed Mar 20 04:55:33 2013]  [<c0247ed4>] call_timer_fn+0x24/0x120
[Wed Mar 20 04:55:33 2013]  [<c0248172>] run_timer_softirq+0x1a2/0x240
[Wed Mar 20 04:55:33 2013]  [<c0240fb9>] __do_softirq+0x99/0x1e0
[Wed Mar 20 04:55:33 2013]  [<c02042f6>] do_softirq+0x76/0xb0
[Wed Mar 20 04:55:33 2013]  [<0000000f>] 0xe
[Wed Mar 20 04:55:33 2013] ---[ end trace dd5a449765340b63 ]---
[Wed Mar 20 04:55:33 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
[Wed Mar 20 04:55:38 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
[Wed Mar 20 04:55:48 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
[Wed Mar 20 04:55:58 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
[Wed Mar 20 04:56:08 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
[Wed Mar 20 04:56:18 2013] ipheth 1-2:4.2: ipheth_tx_timeout: TX timeou=
t
--------------------------------------------------------

The bug also occurs
- when I turn on hotpot first and plug in the cable afterwards.
- with the vanilla kernel from the same repo (and without loading
  the tp_smapi module which taints the kernel in the log above).
- for others (https://bugzilla.novell.com/show_bug.cgi?id=3D779643).
  That link also contains messages from another system with an earlier
  kernel other iphone model and earlier iOS.

What other information is required to get this problem resolved?

Thanks
    J=C3=B6rg
--=20
Joerg Mayer                                           <jmayer@loplof.de=
>
We are stuck with technology when what we really want is just stuff tha=
t
works. Some say that should read Microsoft instead of technology.
