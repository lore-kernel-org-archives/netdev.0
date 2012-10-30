From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: NETDEV WATCHDOG: eth2 (tg3): transmit queue 0 timed out
Date: Mon, 29 Oct 2012 23:57:57 -0700
Message-ID: <1351580277.8764.252.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20121030043213.GE2604@squish.home.loc>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>
To: "Paul Thompson" <set.mailinglist@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1858 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab2J3G6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 02:58:11 -0400
In-Reply-To: <20121030043213.GE2604@squish.home.loc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-30 at 00:32 -0400, Paul Thompson wrote: 
> 	Hi;
> 
> 	Just noticed this in my logs after 10 days uptime. The interface
> is reset and continues to work fine. Looking back through the logs, I
> see it happened in 3.3.0-rc4 for the first time. No occurance from
> 2.6.35.5 util then, and I have run all versions in between. Load on
> the interface is light; just connects to a cable modem.
> 
> Paul
> set.mailinglist@gmail.com
> 
> After this, there is a large dump of hex numbers. If this is signifigant
> let me know and I will supply any more information or testing.

Please provide the full message log from a few seconds before what you
provided below and include those hex numbers.  Please also include the
tg3 signon message for eth2 so that we know what device it is.

Did you run any ethtool command or MTU change around the time of the
watchdog?  Thanks.

> 
> 2012 Oct 29 08:37:25: ------------[ cut here ]------------
> 2012 Oct 29 08:37:25: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x22f/0x240()
> 2012 Oct 29 08:37:25: Hardware name: To Be Filled By O.E.M.
> 2012 Oct 29 08:37:25: NETDEV WATCHDOG: eth2 (tg3): transmit queue 0 timed out
> 2012 Oct 29 08:37:25: Modules linked in: hid_logitech_dj serpent_sse2_x86_64 ablk_helper cryptd glue_helper lrw serpent_generic xts gf128mul cpufreq_ondemand btrfs lzo_decompress lzo_compress libcrc32c dm_crypt dm_mod radeon ttm drm_kms_helper drm backlight i2c_algo_bit cfbcopyarea cfbimgblt cfbfillrect snd_ens1371 snd_rawmidi snd_ac97_codec snd_pcm snd_page_alloc ac97_bus pcspkr [last unloaded: hid_logitech_dj]
> 2012 Oct 29 08:37:25: Pid: 0, comm: swapper/1 Not tainted 3.6.2-low-lat #13
> 2012 Oct 29 08:37:25: Call Trace:
> 2012 Oct 29 08:37:25: <IRQ>  [<ffffffff8134a300>] ? dev_watchdog+0x1c0/0x240
> 2012 Oct 29 08:37:25: [<ffffffff81030329>] ? warn_slowpath_common+0x79/0xc0
> 2012 Oct 29 08:37:25: [<ffffffff81030425>] ? warn_slowpath_fmt+0x45/0x50
> 2012 Oct 29 08:37:25: [<ffffffff8134a36f>] ? dev_watchdog+0x22f/0x240
> 2012 Oct 29 08:37:25: [<ffffffff8134a140>] ? dev_graft_qdisc+0x90/0x90
> 2012 Oct 29 08:37:25: [<ffffffff8103c9cd>] ? run_timer_softirq+0x12d/0x270
> 2012 Oct 29 08:37:25: [<ffffffff810374f4>] ? __do_softirq+0xa4/0x150
> 2012 Oct 29 08:37:25: [<ffffffff813d976c>] ? call_softirq+0x1c/0x30
> 2012 Oct 29 08:37:25: [<ffffffff81003e6d>] ? do_softirq+0x4d/0x80
> 2012 Oct 29 08:37:25: [<ffffffff810378a5>] ? irq_exit+0xa5/0xb0
> 2012 Oct 29 08:37:25: [<ffffffff810202e8>] ? smp_apic_timer_interrupt+0x68/0xa0
> 2012 Oct 29 08:37:25: [<ffffffff813d9087>] ? apic_timer_interrupt+0x67/0x70
> 2012 Oct 29 08:37:25: <EOI>  [<ffffffff8100a25e>] ? default_idle+0x2e/0x50
> 2012 Oct 29 08:37:25: [<ffffffff8100a23e>] ? default_idle+0xe/0x50
> 2012 Oct 29 08:37:25: [<ffffffff8100a3ab>] ? amd_e400_idle+0x7b/0xf0
> 2012 Oct 29 08:37:25: [<ffffffff8100ac56>] ? cpu_idle+0xc6/0xe0
> 2012 Oct 29 08:37:25: ---[ end trace ff857795a2d2309a ]---
> 
> 
