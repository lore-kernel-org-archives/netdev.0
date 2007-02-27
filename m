From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.21-rc1: known regressions (v2) (part 2)
Date: Tue, 27 Feb 2007 09:21:31 +0100
Message-ID: <1172564491.3709.5.camel@chaos>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
	 <20070226220521.GB29575@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David P. Reed" <dpreed@reed.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:37365 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751572AbXB0IVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 03:21:49 -0500
In-Reply-To: <20070226220521.GB29575@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian,

On Mon, 2007-02-26 at 23:05 +0100, Adrian Bunk wrote:
> Subject    : kernel BUG at kernel/time/tick-sched.c:168  (CONFIG_NO_HZ)
> References : http://lkml.org/lkml/2007/2/16/346
> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Handled-By : Thomas Gleixner <tglx@linutronix.de>
> Status     : problem is being debugged

The BUG_ON() was replaced by a warning printk(). The BUG_ON() exposed a
problem with the SMT scheduler. See below.

> Subject    : BUG: soft lockup detected on CPU#0
>              NOHZ: local_softirq_pending 20  (SMT scheduler)
> References : http://lkml.org/lkml/2007/2/20/257
> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> Handled-By : Thomas Gleixner <tglx@linutronix.de>
>              Ingo Molnar <mingo@elte.hu>
> Status     : problem is being debugged

Patch available, not confirmed yet.

	tglx


