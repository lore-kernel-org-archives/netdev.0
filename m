From: poma <pomidorabelisima@gmail.com>
Subject: Re: NETDEV WATCHDOG:  internal(r8152): transmit queue 0 timed out
Date: Fri, 16 Jan 2015 09:24:34 +0100
Message-ID: <54B8CAC2.6020406@gmail.com>
References: <m99j1v$n60$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Community support for Fedora users
	<users@lists.fedoraproject.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:56755 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbbAPIYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 03:24:37 -0500
In-Reply-To: <m99j1v$n60$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.01.2015 00:38, sean darcy wrote:
> I've got F20 on an old laptop I'm using as a router. The external 
> interface uses the RJ45 port. The internal uses a USB ethernet adapter. 
> Every 2-3 weeks, the internal USB adapter fails. I can fix it by just 
> moving it to the other USB port. In another 2-3 weeks, it will fail 
> again, and I move it back to the original USB port, and so on.
> 
> No problems with the external RJ45 interface.
> 
> The logs aren't very helpful:
> 
> 12:39:22 kernel: NETDEV WATCHDOG: internal (r8152): transmit queue 0 
> timed out
> 12:39:22 kernel: Modules linked in: xt_conntrack xt_nat ipt_MASQUERADE 
> xt_DSCP iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 
> nf_nat_ipv4 iptable_raw sch_pie nf_nat_sip nf_nat nf_conntrack_sip 
> nf_conntrack bnep bluetooth arc4 snd_hda_codec_hdmi 
> snd_hda_codec_realtek b43 bcma snd_hda_codec_generic snd_hda_intel 
> snd_hda_controller mac80211 snd_hda_codec uvcvideo snd_hwdep snd_seq 
> snd_seq_device coretemp sdhci_pci snd_pcm acer_wmi videobuf2_vmalloc 
> cfg80211 sparse_keymap microcode sdhci videobuf2_memops iTCO_wdt 
> videobuf2_core rfkill iTCO_vendor_support v4l2_common tg3 ssb cdc_ether 
> ptp joydev pps_core usbnet videodev media i2c_i801 serio_raw mmc_core 
> irda r8152 lpc_ich shpchp tifm_7xx1 snd_timer snd soundcore mfd_core 
> tifm_core crc_ccitt wmi mii acpi_cpufreq firewire_ohci firewire_core 
> crc_itu_t
> 12:39:22 kernel: r8152 2-2:1.0 internal: Tx timeout
> 12:39:23 kernel: r8152 2-2:1.0 internal: Tx timeout
> 12:39:24 kernel: r8152 2-2:1.0 internal: Tx timeout
> ......
> 
> This looks like a USB problem. Is there a way to get usb (or 
> NetworkManager) to reinitialize the driver when this happens?
> 
> sean
> 
> 

I would ask these people for advice, therefore.
