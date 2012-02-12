From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: WARNING: at drivers/net/wireless/ath/ath9k/recv.c:537
 ath_stoprecv+0xed/0x100 [ath9k]()
Date: Sun, 12 Feb 2012 07:56:05 -0800
Message-ID: <20120212075605.7922d4d00adb817577249514@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxkernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


not sure if this ubuntu's issue with the development branch of there software,
but suspending with this machine and waking-up with 
good quality wireless is not consistent.

I have noticed this message in the syslog(but am unsure if its related to the suspend issues
since I was getting other traces with other modules)

[15886.175455] ath: Failed to stop TX DMA, queues=0x005!
[15886.192912] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
[15886.192918] ath: Could not stop RX, we could be confusing the DMA engine when we start RX up
[15886.192920] ------------[ cut here ]------------
[15886.192931] WARNING: at drivers/net/wireless/ath/ath9k/recv.c:537 ath_stoprecv+0xed/0x100 [ath9k]()
[15886.192933] Hardware name: 0914                            
[15886.192935] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat usb_storage cdc_acm usbhid hid parport_pc ppdev dm_crypt ipt_REJECT ipt_LOG xt_limit xt_tcpudp arc4 xt_addrtype ath9k xt_state mac80211 joydev nf_conntrack_netbios_ns nf_conntrack_broadcast snd_hda_codec_hdmi nf_nat_ftp nf_nat snd_hda_codec_conexant ath9k_common snd_hda_intel snd_hda_codec nf_conntrack_ipv4 nf_defrag_ipv4 ath9k_hw snd_hwdep snd_pcm snd_seq_midi snd_rawmidi nf_conntrack_ftp nf_conntrack uvcvideo snd_seq_midi_event videobuf2_core iptable_filter ip_tables ath snd_seq videodev videobuf2_vmalloc videobuf2_memops psmouse intel_ips x_tables cfg80211 snd_timer snd_seq_device snd soundcore snd_page_alloc ideapad_laptop sparse_keymap mei(C) wmi serio_raw lp parport i915 drm_kms_helper drm r8169 i2c_algo_bit video
[15886.192997] Pid: 8687, comm: kworker/u:0 Tainted: G         C   3.3.0-rc3-00172-g3f8aed3 #1
[15886.193014] Call Trace:
[15886.193026]  [<c1042ca2>] warn_slowpath_common+0x72/0xa0
[15886.193033]  [<f8b6816d>] ? ath_stoprecv+0xed/0x100 [ath9k]
[15886.193039]  [<f8b6816d>] ? ath_stoprecv+0xed/0x100 [ath9k]
[15886.193043]  [<c1042cf2>] warn_slowpath_null+0x22/0x30
[15886.193049]  [<f8b6816d>] ath_stoprecv+0xed/0x100 [ath9k]
[15886.193057]  [<f8b63ced>] ath_prepare_reset+0x5d/0xd0 [ath9k]
[15886.193063]  [<f8b6527c>] ath_reset_internal+0x7c/0x160 [ath9k]
[15886.193068]  [<c10a492b>] ? trace_hardirqs_on+0xb/0x10
[15886.193073]  [<f8b657e3>] ath9k_config+0x1f3/0x510 [ath9k]
[15886.193093]  [<f940a975>] ieee80211_hw_config+0x115/0x370 [mac80211]
[15886.193107]  [<f9412d5a>] ieee80211_scan_work+0x1ca/0x6b0 [mac80211]
[15886.193111]  [<c1062726>] process_one_work+0x166/0x5b0
[15886.193115]  [<c10626b2>] ? process_one_work+0xf2/0x5b0
[15886.193120]  [<c12c6eab>] ? do_raw_spin_lock+0x3b/0xf0
[15886.193132]  [<f9412b90>] ? ieee80211_scan_rx+0x1b0/0x1b0 [mac80211]
[15886.193139]  [<c1062e84>] worker_thread+0x124/0x2c0
[15886.193142]  [<c1062d60>] ? rescuer_thread+0x1c0/0x1c0
[15886.193145]  [<c10674fd>] kthread+0x7d/0x90
[15886.193149]  [<c1067480>] ? __init_kthread_worker+0x60/0x60
[15886.193155]  [<c158fec2>] kernel_thread_helper+0x6/0x10
[15886.193157] ---[ end trace 883570b757402f86 ]---
[15886.271478] ath: Failed to stop TX DMA, queues=0x001!

full dmesg is here:
http://fpaste.org/Uo91/

I will continue to watch this, and let you know if I see anything.
the wireless card is:
lspci:
05:00.0 Network controller: Atheros Communications Inc. AR9285 Wireless Network Adapter (PCI-Express) (rev 01)

-- 
Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
