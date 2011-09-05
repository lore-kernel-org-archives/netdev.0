From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: 3.1-rc2: (on a second machine): WARNING: at net/sched/sch_generic.c:255
 dev_watchdog+0x23f/0x250()
Date: Mon, 5 Sep 2011 08:36:11 -0400 (EDT)
Message-ID: <alpine.DEB.2.02.1109050834430.23828@p34.internal.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org, Alan Piszcz <ap@solarrain.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:53775 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab1IEMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 08:36:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Kernel crash: 3.1-rc2:

Sep  5 08:28:36 l1 kernel: [1194854.704017] ------------[ cut here ]------------
Sep  5 08:28:36 l1 kernel: [1194854.704030] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x23f/0x250()
Sep  5 08:28:36 l1 kernel: [1194854.704033] Hardware name: P35-DS4
Sep  5 08:28:36 l1 kernel: [1194854.704036] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
Sep  5 08:28:36 l1 kernel: [1194854.704039] Modules linked in: tcp_diag ub ppdev lp inet_diag w83795 ipmi_msghandler dm_mod nouveau ttm snd_hda_codec_realtek snd_hda_intel snd_hda_codec drm_kms_helper snd_pcm_oss snd_mixer_oss drm snd_pcm i2c_algo_bit mxm_wmi wmi intel_agp intel_gtt agpgart floppy snd_timer firewire_ohci firewire_core video snd soundcore snd_page_alloc parport_pc parport
Sep  5 08:28:36 l1 kernel: [1194854.704077] Pid: 19, comm: ksoftirqd/3 Not tainted 3.1.0-rc2 #1
Sep  5 08:28:36 l1 kernel: [1194854.704080] Call Trace:
Sep  5 08:28:36 l1 kernel: [1194854.704088]  [<ffffffff810372da>] warn_slowpath_common+0x7a/0xb0
Sep  5 08:28:36 l1 kernel: [1194854.704093]  [<ffffffff810373b1>] warn_slowpath_fmt+0x41/0x50
Sep  5 08:28:36 l1 kernel: [1194854.704099]  [<ffffffff815ee154>] ? schedule+0x2e4/0x950
Sep  5 08:28:36 l1 kernel: [1194854.704103]  [<ffffffff814fbc7f>] dev_watchdog+0x23f/0x250
Sep  5 08:28:36 l1 kernel: [1194854.704109]  [<ffffffff81043162>] run_timer_softirq+0xf2/0x220
Sep  5 08:28:36 l1 kernel: [1194854.704113]  [<ffffffff814fba40>] ? qdisc_reset+0x50/0x50
Sep  5 08:28:36 l1 kernel: Sep  5 08:31:47 l1 syslogd 1.5.0#6.1: restart (remote reception).

Thoughts?

Justin.
