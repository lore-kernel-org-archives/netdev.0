From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 13:21:00 -0700 (PDT)
Message-ID: <20080721.132100.128525904.davem@davemloft.net>
References: <4884DFEE.4060003@lwfinger.net>
	<20080721193425.GA29287@elte.hu>
	<4884E6E6.7010800@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-X9Un+BFzKDI@public.gmane.org, ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	j@w1.fi
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4884E6E6.7010800-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date: Mon, 21 Jul 2008 14:43:34 -0500

> Jul 21 12:19:37 larrylap kernel: kernel BUG at net/core/dev.c:1328!
> Jul 21 12:19:37 larrylap kernel: invalid opcode: 0000 [1] SMP
> Jul 21 12:19:37 larrylap kernel: CPU 0
> Jul 21 12:19:37 larrylap kernel: Modules linked in: af_packet rfkill_input nfs 
> lockd nfs_acl sunrpc cpufreq_conservative cpu
> freq_userspace cpufreq_powersave powernow_k8 fuse loop dm_mod arc4 ecb 
> crypto_blkcipher b43 firmware_class rfkill mac80211 c
> fg80211 snd_hda_intel snd_pcm snd_timer led_class snd k8temp input_polldev 
> sr_mod soundcore button battery hwmon cdrom force
> deth ac serio_raw ssb snd_page_alloc sg ehci_hcd sd_mod ohci_hcd usbcore edd fan 
> thermal processor ext3 mbcache jbd pata_amd
>   ahci libata scsi_mod dock
> Jul 21 12:19:37 larrylap kernel: Pid: 2057, comm: b43 Not tainted 
> 2.6.26-Linus-git-05253-g14b395e #1
> Jul 21 12:19:37 larrylap kernel: RIP: 0010:[<ffffffff8039ec4d>] 
> [<ffffffff8039ec4d>] __netif_schedule+0x12/0x75
> Jul 21 12:19:37 larrylap kernel: RSP: 0000:ffff8800b9ae1de0  EFLAGS: 00010246
> 
> With an invalid opcode, mine is likely due to stack corruption.

No further backtrace?  That will tell us what driver is causing
this.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
