From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: transmit timed out on module reload
Date: Fri, 20 Jun 2008 11:35:39 -0300
Message-ID: <20080620113539.25347b90@doriath.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	salem@mandriva.com
To: venza@brownhat.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758512AbYFTOft@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 Hi there.

 We have a machine here which can trig the following warning if we
remove its network module (sis900) and let ifplugd reload it:

"""
WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xfa/0x120()
Modules linked in: sis900 ip_set fuse af_packet snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss ipv6 binfmt_misc loop dm_mod floppy cpufreq_ondemand cpufreq_conservative cpufreq_powersave p4_clockmod speedstep_lib freq_table ns558 gameport parport_pc parport rtc_cmos button thermal processor snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd soundcore sr_mod snd_page_alloc sis_agp agpgart i2c_sis96x i2c_core mii shpchp pci_hotplug evdev sg ide_generic sis5513 ide_core pata_sis libata dock sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
usbcore [last unloaded: sis900]
Pid: 0, comm: swapper Not tainted 2.6.26-desktop-0.rc6.1mnb #1
 [<c012da14>] warn_on_slowpath+0x54/0xa0
 [<c012e146>] ? wake_up_klogd+0x36/0x40
 [<c012439b>] ? default_wake_function+0xb/0x10
 [<c014252b>] ? autoremove_wake_function+0x1b/0x50
 [<de841965>] ? sis900_tx_timeout+0x125/0x180 [sis900]
 [<c02f2a3a>] dev_watchdog+0xfa/0x120
 [<c013768b>] run_timer_softirq+0x12b/0x1f0
 [<c02f2940>] ? dev_watchdog+0x0/0x120
 [<c02f2940>] ? dev_watchdog+0x0/0x120
 [<c01332e2>] __do_softirq+0x92/0x120
 [<c01333cd>] do_softirq+0x5d/0x60
 [<c0133565>] irq_exit+0x75/0xa0
 [<c0115508>] smp_apic_timer_interrupt+0x58/0x90
 [<c010a640>] ? mwait_idle+0x0/0x50
 [<c0104968>] apic_timer_interrupt+0x28/0x30
 [<c010a640>] ? mwait_idle+0x0/0x50
 [<c010a672>] ? mwait_idle+0x32/0x50
 [<c0102d6b>] cpu_idle+0x6b/0xf0
 [<c035df89>] start_secondary+0x16c/0x1e3
 =======================
---[ end trace 756c1e519796d652 ]---
"""

 Doesn't seem serious though, the card still works.

 Despite the kernel name, it's a vanilla 2.6.26-rc6-git3 kernel.

-- 
Luiz Fernando N. Capitulino
