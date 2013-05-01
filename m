From: Milan Kocian <milon@wq.cz>
Subject: WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
 (probably iwl4965)
Date: Wed, 1 May 2013 11:08:18 +0200
Message-ID: <20130501090818.GA5907@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([80.92.240.241]:58983 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758837Ab3EAJVe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 05:21:34 -0400
Received: from [82.202.95.52] (helo=ntm.wq.cz)
	by srw1.wq.cz with esmtpsa (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <milon@wq.cz>)
	id 1UXT1W-0002an-Hv
	for netdev@vger.kernel.org; Wed, 01 May 2013 11:08:26 +0200
Received: from milon by ntm.wq.cz with local (Exim 4.80)
	(envelope-from <milon@wq.cz>)
	id 1UXT1O-0001ZA-Ez
	for netdev@vger.kernel.org; Wed, 01 May 2013 11:08:18 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello,

after upgrade to the kernel v3.9 I see this nice warning after every reboot.

------------[ cut here ]------------
WARNING: at kernel/softirq.c:160 local_bh_enable_ip+0x7a/0xb0()
Hardware name: 76693KG
Modules linked in: cpufreq_userspace cpufreq_stats cpufreq_powersave cpufreq_ondemand cpufreq_conservative ipv6 rfcomm nfnetlink_log nfnetlink bnep deflate zlib_deflate zlib_inflate ctr twofish_x86_64_3way twofish_x86_64 twofish_common camellia_generic camellia_x86_64 serpent_sse2_x86_64 serpent_generic xts lrw gf128mul glue_helper blowfish_generic blowfish_x86_64 blowfish_common cast5_generic cast_common ablk_helper cryptd des_generic xcbc rmd160 sha512_generic sha1_ssse3 sha1_generic hmac crypto_null af_key xfrm_algo sha256_generic md_mod uinput usbhid fuse snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_hwdep arc4 btusb snd_pcm_oss snd_mixer_oss snd_pcm i915 thinkpad_acpi snd_page_alloc cfbfillrect cfbimgblt bluetooth crc16 iwl4965 iwlegacy mac80211 snd_seq_dummy acpi_cpufreq snd_s
 eq_oss i2c_algo_bit snd_seq_midi cfg80211 firewire_ohci firewire_core crc_itu_t mperf snd_rawmidi cfbcopyarea pcmcia ehci_pci coretemp e1000e iTCO_wdt sdhci_pci drm_kms_helper drm lpc_ich uhci_hcd ehci_hcd snd_seq_midi_event yenta_socket pcmcia_rsrc pcmcia_core sdhci mfd_core mmc_core snd_seq usbcore kvm_intel kvm tpm_tis tpm tpm_bios snd_seq_device snd_timer i2c_i801 i2c_core microcode usb_common snd video rfkill ptp pps_core soundcore
Pid: 5812, comm: wpa_supplicant Not tainted 3.9.0 #57
Call Trace:
 [<ffffffff81036829>] ? warn_slowpath_common+0x79/0xc0
 [<ffffffff8103d71a>] ? local_bh_enable_ip+0x7a/0xb0
 [<ffffffffa0329014>] ? il4965_tx_skb+0xc04/0xd50 [iwl4965]
 [<ffffffffa02ba281>] ? ieee80211_crypto_tkip_encrypt+0x141/0x1d0 [mac80211]
 [<ffffffff810f63d0>] ? __kmalloc+0x110/0x120
 [<ffffffffa0329170>] ? il4965_mac_tx+0x10/0x30 [iwl4965]
 [<ffffffffa02d1948>] ? __ieee80211_tx+0x138/0x370 [mac80211]
 [<ffffffffa02d3e4e>] ? ieee80211_tx+0xee/0x120 [mac80211]
 [<ffffffffa02d4f0f>] ? ieee80211_subif_start_xmit+0xb4f/0xd20 [mac80211]
 [<ffffffff81352f40>] ? __skb_recv_datagram+0x110/0x300
 [<ffffffff8135c08e>] ? dev_hard_start_xmit+0x21e/0x460
 [<ffffffff8134fe20>] ? __alloc_skb+0x90/0x2a0
 [<ffffffff8137653d>] ? sch_direct_xmit+0xed/0x1e0
 [<ffffffff8135c4b9>] ? dev_queue_xmit+0x1e9/0x460
 [<ffffffff813ecf1e>] ? packet_sendmsg+0xd7e/0xe60
 [<ffffffff81343e8b>] ? sock_sendmsg+0x7b/0xb0
 [<ffffffff813448f3>] ? move_addr_to_user+0x73/0xd0
 [<ffffffff81346fce>] ? sys_sendto+0xfe/0x150
 [<ffffffff8111ce25>] ? mntput_no_expire+0x25/0x170
 [<ffffffff813475b4>] ? sys_recvmsg+0x44/0x80
 [<ffffffff8140e5d6>] ? system_call_fastpath+0x1a/0x1f
---[ end trace 6443164a8c19ebbd ]---

If you need more info I will send them. Feel free to send patches
I will test them :-).

Best regards,

-- 
Milan Kocian
