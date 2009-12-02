From: Chris Rankin <rankincj@yahoo.com>
Subject: [WARNING] Network-related warnings with 2.6.31.6
Date: Tue, 1 Dec 2009 16:34:57 -0800 (PST)
Message-ID: <43332.67750.qm@web52904.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754955AbZLBAle@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've just noticed these warnings in my dmesg log, and have no idea what might have triggered them. e1000 related, perhaps?

Cheers,
Chris

------------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/core/stream.c:202 inet_csk_destroy_sock+0x77/0xd3()
Hardware name: Precision WorkStation 650    
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
 cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Not tainted 2.6.31.6 #1
Call Trace:
 [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
 [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
 [<c11871ca>] ? inet_csk_destroy_sock+0x77/0xd3
 [<c119188f>] ? tcp_rcv_state_process+0x81f/0x9e8
 [<c11966c3>] ? tcp_v4_do_rcv+0x128/0x16d
 [<c1196b0d>] ? tcp_v4_rcv+0x405/0x640
 [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
 [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
 [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
 [<c116b7c5>] ? netif_receive_skb+0x261/0x281
 [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
 [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
 [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
 [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
 [<c11c769b>] ? _spin_lock_irq+0xe/0x24
 [<c116bce5>] ? net_rx_action+0x57/0xfd
 [<c1027ea3>] ? __do_softirq+0x7a/0xe3
 [<c1027e29>] ? __do_softirq+0x0/0xe3
 <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
 [<c1004320>] ? do_IRQ+0x7c/0x8d
 [<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf3 ]---
------------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:151 inet_sock_destruct+0xd8/0x138()
Hardware name: Precision WorkStation 650    
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
 cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Tainted: G        W  2.6.31.6 #1
Call Trace:
 [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
 [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
 [<c11a1414>] ? inet_sock_destruct+0xd8/0x138
 [<c1163243>] ? __sk_free+0x10/0xa2
 [<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
 [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
 [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
 [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
 [<c116b7c5>] ? netif_receive_skb+0x261/0x281
 [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
 [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
 [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
 [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
 [<c11c769b>] ? _spin_lock_irq+0xe/0x24
 [<c116bce5>] ? net_rx_action+0x57/0xfd
 [<c1027ea3>] ? __do_softirq+0x7a/0xe3
 [<c1027e29>] ? __do_softirq+0x0/0xe3
 <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
 [<c1004320>] ? do_IRQ+0x7c/0x8d
 [<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf4 ]---
------------[ cut here ]------------
WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:154 inet_sock_destruct+0x11e/0x138()
Hardware name: Precision WorkStation 650    
Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nfsd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer firewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_util_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcache sr_mod cdrom sd_mo
 d pata_acpi sata_sil uhci_hcd ata_piix libata scsi_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agpgart i2c_algo_bit cfbcopyarea cfbimgblt
 cfbfillrect [last unloaded: processor]
Pid: 32056, comm: rpm Tainted: G        W  2.6.31.6 #1
Call Trace:
 [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
 [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
 [<c11a145a>] ? inet_sock_destruct+0x11e/0x138
 [<c1163243>] ? __sk_free+0x10/0xa2
 [<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
 [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
 [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
 [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
 [<c116b7c5>] ? netif_receive_skb+0x261/0x281
 [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
 [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
 [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
 [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
 [<c11c769b>] ? _spin_lock_irq+0xe/0x24
 [<c116bce5>] ? net_rx_action+0x57/0xfd
 [<c1027ea3>] ? __do_softirq+0x7a/0xe3
 [<c1027e29>] ? __do_softirq+0x0/0xe3
 <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
 [<c1004320>] ? do_IRQ+0x7c/0x8d
 [<c1002f29>] ? common_interrupt+0x29/0x30
---[ end trace e643d9455a26ccf5 ]---



      
