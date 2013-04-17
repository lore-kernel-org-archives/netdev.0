From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 11:19:18 +0200
Message-ID: <516E6916.3000804@linutronix.de>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38112 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab3DQJTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 05:19:20 -0400
In-Reply-To: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2013 08:21 PM, Sebastian Andrzej Siewior wrote:
> In my testing I didn't notice anything unusual except one thing: I start
> a wget of a 126MiB file (which is sttored on MMC) from the beagle bone.
> On the first invocation I receive almost steady 5MiB/sec. In the
> following invocations of wget I see the performance floating between
> 1MiB/sec and 4MiB/sec. It usually ends with overall around 2MiB/sec.
> I couldn't notice nothing wrong. The only difference compared to the
> first invocation is (most likely) that the file is now served from
> memory and not read from MMC which should perform better but not worse.
> After executing "while ((1)); do /bin/true; done" on the beagle bone
> while the file was downloaded, I noticed that the speed rose to 9MiB/sec
> - 10/MiB/sec. Now this looks like power/idle optimization on the beagle
> bone side.

Yeah, disabling NO_HZ gives 11.2 MiB/s.

Sebastian
