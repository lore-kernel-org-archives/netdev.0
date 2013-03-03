From: Dave Jones <davej@redhat.com>
Subject: e1000e disabling already-disabled device
Date: Sun, 3 Mar 2013 11:21:24 -0500
Message-ID: <20130303162124.GA31371@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab3CCQV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Mar 2013 11:21:27 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r23GLQwl020384
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 3 Mar 2013 11:21:27 -0500
Received: from gelk.kernelslacker.org (ovpn-113-131.phx2.redhat.com [10.3.113.131])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r23GLPvI006387
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 3 Mar 2013 11:21:26 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.6/8.14.5) with ESMTP id r23GLO1W031462
	for <netdev@vger.kernel.org>; Sun, 3 Mar 2013 11:21:24 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.6/8.14.6/Submit) id r23GLOFL031461
	for netdev@vger.kernel.org; Sun, 3 Mar 2013 11:21:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saw this when I suspended my laptop.


 ------------[ cut here ]------------
 WARNING: at drivers/pci/pci.c:1397 pci_disable_device+0x90/0xa0()
 Hardware name: 2356JK8
 Device e1000e
disabling already-disabled device
Modules linked in:
 dm_crypt arc4 iwldvm mac80211 ipv6 iTCO_wdt xfs iTCO_vendor_support libcrc32c coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode snd_hda_codec_hdmi snd_hda_codec_realtek btusb bluetooth iwlwifi pcspkr snd_hda_intel cfg80211 snd_hda_codec snd_pcm lpc_ich mfd_core e1000e snd_page_alloc ptp pps_core thinkpad_acpi hwmon led_class rfkill wmi nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit drm_kms_helper drm i2c_core video
Pid: 19776, comm: kworker/u:11 Not tainted 3.8.0+ #6
Call Trace:
 [<ffffffff81049855>] warn_slowpath_common+0x75/0xa0
 [<ffffffff81049936>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff81359760>] pci_disable_device+0x90/0xa0
 [<ffffffffa0251092>] __e1000_shutdown+0x262/0x8a0 [e1000e]
 [<ffffffffa0251743>] e1000_suspend+0x23/0x50 [e1000e]
 [<ffffffff816284b9>] ? sub_preempt_count+0x79/0xd0
 [<ffffffff8135bd97>] pci_pm_suspend+0x77/0x140
 [<ffffffff8135bd20>] ? pci_pm_poweroff+0xf0/0xf0
 [<ffffffff8140c678>] dpm_run_callback+0x58/0x90
 [<ffffffff8140c79d>] __device_suspend+0xed/0x280
 [<ffffffff8140d1ef>] async_suspend+0x1f/0xa0
 [<ffffffff8107e3a6>] async_run_entry_fn+0x46/0x140
 [<ffffffff8106de9b>] process_one_work+0x20b/0x6b0
 [<ffffffff8106de2f>] ? process_one_work+0x19f/0x6b0
 [<ffffffff8106e720>] worker_thread+0x110/0x380
 [<ffffffff8106e610>] ? rescuer_thread+0x290/0x290
 [<ffffffff8107566d>] kthread+0xed/0x100
 [<ffffffff81075580>] ? kthread_create_on_node+0x160/0x160
 [<ffffffff8162caac>] ret_from_fork+0x7c/0xb0
 [<ffffffff81075580>] ? kthread_create_on_node+0x160/0x160
---[ end trace afe8ab959e3ef1ea ]---
