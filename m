From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 14:14:33 +0200
Message-ID: <1371384873.8546.3.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130613222411.GA5396@sig21.net>
	 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
	 <20130614055346.GB6547@sig21.net>
	 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
	 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
	 <20130616094930.GA5899@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58556 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab3FPMOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 08:14:37 -0400
In-Reply-To: <20130616094930.GA5899@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-16 at 11:49 +0200, Johannes Stezenbach wrote:

> Another thing: suspend to disk fails (also happened with QCA driver):
> 
> Jun 16 00:54:32 abc kernel: [93820.564582] Suspending console(s) (use no_console_suspend to debug)
> Jun 16 00:54:32 abc kernel: [93820.568633] serial 00:0a: disabled
> Jun 16 00:54:32 abc kernel: [93820.568644] serial 00:0a: System wakeup disabled by ACPI
> Jun 16 00:54:32 abc kernel: [93820.569407] alx 0000:03:00.0: PHY SPD/DPLX unresolved: 0xffff
> Jun 16 00:54:32 abc kernel: [93820.569410] alx 0000:03:00.0: shutdown fail in suspend -22
> Jun 16 00:54:32 abc kernel: [93820.569417] pci_pm_freeze(): alx_suspend+0x0/0x75 returns -22
> Jun 16 00:54:32 abc kernel: [93820.569421] dpm_run_callback(): pci_pm_freeze+0x0/0x8f returns -22
> Jun 16 00:54:32 abc kernel: [93820.569427] PM: Device 0000:03:00.0 failed to freeze async: error -22

It failed differently for me, which I've fixed. However, it doesn't
resume properly (device doesn't actually work until you down/up cycle
it), I'll poke at that later.

http://p.sipsolutions.net/04bb9ce0a6586437.txt

johannes
