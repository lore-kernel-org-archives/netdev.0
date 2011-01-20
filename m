From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Thu, 20 Jan 2011 10:04:07 +0700
Message-ID: <AANLkTikxpOS2fJ1Sqv=Lg6cX1TE+1W-ZxFV+YMOH1+Yp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: 609538@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49802 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab1ATDEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 22:04:07 -0500
Received: by iwn9 with SMTP id 9so119824iwn.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 19:04:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When resuming from suspended with 2.6.38-rc1 with my RTL8168d/8111d
hardware, I see significant delays [1].

The only firmware I see in /lib/firmware is RTL8192E, thus it looks
like this is due to it being not present.

I see that Francois' patch is present in 2.6.38-rc1; is there a way to
avoid this delay, or is this likely in request_firmware?

Thanks,
  Daniel

--- [1]

[21786.797521] sdhci-pci 0000:09:00.0: Will use DMA mode even though
HW doesn't fully claim to support it.
[21786.797530] sdhci-pci 0000:09:00.0: setting latency timer to 64
[21847.280237] r8169 0000:0b:00.0: eth0: unable to apply firmware patch
[21847.283688] PM: resume of devices complete after 61090.398 msecs
[21848.934980] Synaptics Touchpad, model: 1, fw: 7.2, id: 0x1c0b1,
caps: 0xd04733/0xa40000/0xa0000
[21848.980306] input: SynPS/2 Synaptics TouchPad as
/devices/platform/i8042/serio1/input/input12
[21850.886820] PM: Finishing wakeup.
[21850.888808] Restarting tasks ... done.
[21851.384291] r8169 0000:0b:00.0: eth0: unable to apply firmware patch
[21851.386090] r8169 0000:0b:00.0: eth0: link down
[21853.324784] EXT4-fs (sda1): re-mounted. Opts: commit=0
-- 
Daniel J Blueman
