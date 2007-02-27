From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.21-rc1: known regressions (v2) (part 2)
Date: Tue, 27 Feb 2007 09:33:49 +0100
Message-ID: <20070227083349.GB30376@elte.hu>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org> <20070226220521.GB29575@stusta.de> <1172564491.3709.5.camel@chaos> <45E3ECF1.4040906@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>, Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David P. Reed" <dpreed@reed.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>,
	Mike Galbraith <efault@gmx.de>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52006 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030583AbXB0IoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 03:44:19 -0500
Content-Disposition: inline
In-Reply-To: <45E3ECF1.4040906@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Thomas Gleixner napisa=C5=82(a):
> > Adrian,
> >=20
> > On Mon, 2007-02-26 at 23:05 +0100, Adrian Bunk wrote:
> >> Subject    : kernel BUG at kernel/time/tick-sched.c:168  (CONFIG_N=
O_HZ)
> >> References : http://lkml.org/lkml/2007/2/16/346
> >> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> >> Handled-By : Thomas Gleixner <tglx@linutronix.de>
> >> Status     : problem is being debugged
> >=20
> > The BUG_ON() was replaced by a warning printk(). The BUG_ON() expos=
ed a
> > problem with the SMT scheduler. See below.
> >=20
> >> Subject    : BUG: soft lockup detected on CPU#0
> >>              NOHZ: local_softirq_pending 20  (SMT scheduler)
> >> References : http://lkml.org/lkml/2007/2/20/257
> >> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
> >> Handled-By : Thomas Gleixner <tglx@linutronix.de>
> >>              Ingo Molnar <mingo@elte.hu>
> >> Status     : problem is being debugged
> >=20
> > Patch available, not confirmed yet.
> >=20
>=20
> I can confirm that the bug is fixed (over 20 hours of testing should=20
> be enough).

thanks alot! I think this thing was a long-term performance/latency=20
regression in HT scheduling as well.

	Ingo
