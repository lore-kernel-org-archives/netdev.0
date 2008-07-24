From: "Fabio Comolli" <fabio.comolli@gmail.com>
Subject: Re: WARNING: at net/core/dev.c:1330 __netif_schedule+0x23/0x77()
Date: Thu, 24 Jul 2008 11:30:28 +0200
Message-ID: <b637ec0b0807240230x16cd8912t4d742ef647b0807d@mail.gmail.com>
References: <b637ec0b0807221205j4d212486r32785626caa44617@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:51444 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbYGXJa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 05:30:29 -0400
Received: by an-out-0708.google.com with SMTP id d40so614953and.103
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 02:30:28 -0700 (PDT)
In-Reply-To: <b637ec0b0807221205j4d212486r32785626caa44617@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Added netdev to CC: list]


On Tue, Jul 22, 2008 at 9:05 PM, Fabio Comolli <fabio.comolli@gmail.com> wrote:
> Another on of the net/core/dev.c saga. This looks different from the
> others seen on lkml though. Triggered after a suspend/resume cycle.
> Regards,
> Fabio
>
>
>
> ------------[ cut here ]------------
> WARNING: at net/core/dev.c:1330 __netif_schedule+0x23/0x77()
> Modules linked in: michael_mic arc4 ecb ieee80211_crypt_tkip microcode
> snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device cpufreq_conservative
> cpufreq_powersave acpi_cpufreq loop dm_mod pcmcia battery ac
> firewire_ohci ipw2200 snd_intel8x0 firewire_core yenta_socket
> rsrc_nonstatic ieee80211 8139too snd_ac97_codec crc_itu_t mii
> ieee80211_crypt pcmcia_core ac97_bus button uhci_hcd snd_pcm 8250_pci
> snd_timer iTCO_wdt ehci_hcd snd soundcore snd_page_alloc 8250
> serial_core i2c_i801 usbcore sg
> Pid: 3643, comm: s2ram Not tainted 2.6.26-05752-g93ded9b #27
>  [<c0118b18>] warn_on_slowpath+0x40/0x79
>  [<c01079d3>] native_sched_clock+0x77/0x88
>  [<c027110e>] pci_conf1_write+0xb2/0xc0
>  [<c01315f4>] lock_release_holdtime+0x16/0x124
>  [<c027110e>] pci_conf1_write+0xb2/0xc0
>  [<c01079d3>] native_sched_clock+0x77/0x88
>  [<c01327e0>] mark_held_locks+0x46/0x5d
>  [<c02d190f>] _spin_unlock_irqrestore+0x34/0x39
>  [<c013294c>] trace_hardirqs_on_caller+0xdd/0xfd
>  [<c01dfd77>] pci_bus_write_config_dword+0x46/0x50
>  [<c027d6f8>] __netif_schedule+0x23/0x77
>  [<c027d84d>] netif_device_attach+0x31/0x3b
>  [<f895381e>] ipw_pci_resume+0x8a/0xa3 [ipw2200]
>  [<c01e3b8b>] pci_legacy_resume+0x13/0x16
>  [<c022baa1>] pm_op+0x52/0xac
>  [<c022c080>] device_resume+0x8e/0x2ed
>  [<c013af11>] suspend_devices_and_enter+0xe8/0x10c
>  [<c013b025>] enter_state+0xaf/0xf8
>  [<c013b0f5>] state_store+0x87/0x9a
>  [<c013b06e>] state_store+0x0/0x9a
>  [<c01cd4c3>] kobj_attr_store+0x18/0x1c
>  [<c018f6bd>] sysfs_write_file+0xb5/0xe2
>  [<c018f608>] sysfs_write_file+0x0/0xe2
>  [<c015e40c>] vfs_write+0x84/0xf7
>  [<c015e517>] sys_write+0x3c/0x63
>  [<c0103709>] sysenter_past_esp+0x6a/0xa5
>  =======================
> ---[ end trace 96b882348301a484 ]---
>
