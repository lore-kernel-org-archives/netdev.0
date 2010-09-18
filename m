From: Josh Cartwright <joshc@linux.com>
Subject: Fw: Kernel panic in 2.6.36-rc4 after suspend/resume
Date: Sat, 18 Sep 2010 16:47:33 -0500
Message-ID: <20100918214733.GA5223@kryptos.lan>
Reply-To: vaibhav_agrwal@yahoo.co.in
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<Forwarding to relevant maintainers (get_maintainer.pl -f net/mac80211/agg-tx.c)>

From: vaibhav agarwal <vaibhav_agrwal@yahoo.co.in>
Subject: Re: Kernel panic in 2.6.36-rc4 after suspend/resume
Date: Sat, 18 Sep 2010 15:09:29 +0530 (IST)
To: linux-kernel@vger.kernel.org
X-Mailer: YahooMailRC/497 YahooMailWebService/0.8.105.279950

Hi,

I am using kernel 2.6.34-rc4 directly taken from kernel.org. After suspend to 
ram if I leave it for few hours and resume then kernel panic happens (screen of 
death). If I suspend and resume immediately then it works fine.

I have hand copied the message and attached in this mail. Let me know what other 


information is needed from my side.
I can file bug in kernel bugzilla if needed. As per kernel oops docs, I am 
sending a mail here.

(Its a intel Dual Core machine)

-vaibhav


Modules linked in: btusb i915 drm_kms_helper drm i2c_algo_bit sco acpi_cpufreq 
mperf rfcomm bnep cpufreq_powersave l2cap crc16 bluetooth cpufreq_userspace 
cpufreq_conservative cpufreq_stats nfsd exportfs nfs lockd fscache nfs_acl 
auth_rpcgss sunrpc aes_1586 aes_generic fuse loop arc4 ecb ath9k mac80211 
snd_hda_codec_intelhdmi ath9k common snd_hda_codec_realtek ath9k_hw ath 
snd_hda_codec snd_hwdep cfg90211 snd_pcm_oss snd_mixer_oss snd_pcm intel_agp 
snd_seq_midi jmb38x_ms uvcvideo videodev snd_rawmidi snd_seq_midi_event joydev 
v4l1_compat rfkill memstick snd_seq shpchp evdev tpm_tis tpm agppart tpm_bios 
video battery processor ac snd_timer snd_seq_device psmouse snd serio_raw pcspkr 
i2c_i801 i2c_core soundcore pci_hotplug output snd_page_alloc wmi button ext3 
jbd mbcache sg sr_mod cdrom crc_t10dif uhci_hcd ahci libahci libata ehci_hcd 
sdhci_pci sdhci atl1e thermal mmc_core led_class scsi_mod thermal_sys usbcore 
nls_base [last unloaded: scsi_wait_scan]

Pid: 0, comm: swapper Not tainted 2.6.36-rc4-custom #18 Aspire 4736Z    /Aspire 
4736Z
EIP: 0060:[<f83de653>] Eflags: 00010206 CPU: 0
EIP is ay sta_addba_resp_timer_expired+0x17/0x28 [max80211]
EAX: f4b8ff6c EBS: f36b7848 ECX: 052f0000 EDX: 00000094
ESI: c04fd340 EDI: 00000001 EBP: 00000100 ESP: c0431eec
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0430000 task=c043ff20 task.ti=c0430000)
Stack:
 c013908f c0431f0c f83de63c c04fdb50 c04fdd50 c04fdf50 c04fe150 f4b901a0
<0> c0431f0c c0431f0c 00000046 00000004 00000001 00000100 c0133eb4 00000001
<0> 0000000a c0435a04 c04c1dec 00000000 00000046 00000000 00000000 c0431f70
Call Trace:
 [<c013908f>] ? run_timer_softirq+0x16f/0x213
 [<f83de63c>] ? sta_addba_resp_timer_expired+0x0/0x28 [mac80211]
 [<c0133eb4>] ? __do_softirq+0xb1/0x156
 [<c0133f87>] ? do_softirq+0x2e/0x38
 [<c0134085>] ? irq_exit+0x26/0x58
 [<c01043d0>] ? do_IRQ+0x7d/0x8e
 [<c01033a9>] ? common_interrupt+0x29/0x30
 [<f8534f9d>] ? acpi_idle_enter_simple+0xec/0x129 [processor]
 [<c02b34ae>] ? cpuidle_idle_call+0x77/0xd5
 [<c01021c6>] ? cpu_idle+0x49/0x8b
 [<c046883e>] ? start_kernel+0x2d4/0x2d7
Code: e8 2f c4 f7 c7 eb 05 bd ea ff ff ff 5e 89 e8 5b 5e 5f 5d c3 0f b6 10 29 d0 
2d a0 01 00 00 8d 8c 90 4c 01 00 00 8b 09 85 c9 74 10 <f6> 41 4c 02 75 0a 05 b0 
01 00 00 e9 5f ff ff ff c3 55 89 cd 57
EIP: [<f83de653>] sta_addba_resp_expired+0x17/0x28 [max80211] SS:ESP 
0068:c0431eec
CR2: 00000000052f004c
---[ end trace c7cc1d8c9381c37c ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G        D       2.6.36-rc4-custom #18
Call Trace:
 [<c03591ba>] ? panic+0x4d/0x13a
 [<c0105692>] ? oops_end+0x8e/0x99
 [<c011d6c4>] ? no_context+0x10d/0x116
 [<c011da13>] ? do_page_fault+0x0/0x24d
 [<c011d7d2>] ? bad_area_nosemaphore+0xa/0xc
 [<c035b316>] ? error_code+0x5a/0x60
 [<c011da13>] ? do_page_fault+0x0/0x24d
 [<f83de653>] ? sta_addba_resp_timer_expired+0x17/0x28 [mac80211]
 [<c013908f>] ? run_timer_softirq+0x16f/0x213

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

----- End forwarded message -----
