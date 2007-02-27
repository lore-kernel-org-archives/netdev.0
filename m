From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.21-rc1: known regressions (v2) (part 2)
Date: Tue, 27 Feb 2007 09:33:53 +0100
Message-ID: <45E3ECF1.4040906@googlemail.com>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>	 <20070226220521.GB29575@stusta.de> <1172564491.3709.5.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@stusta.de>,
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
	Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:6736 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbXB0IfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 03:35:05 -0500
Received: by nf-out-0910.google.com with SMTP id o25so109967nfa
        for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 00:35:03 -0800 (PST)
In-Reply-To: <1172564491.3709.5.camel@chaos>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Gleixner napisa=B3(a):
> Adrian,
>=20
> On Mon, 2007-02-26 at 23:05 +0100, Adrian Bunk wrote:
>> Subject    : kernel BUG at kernel/time/tick-sched.c:168  (CONFIG_NO_=
HZ)
>> References : http://lkml.org/lkml/2007/2/16/346
>> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
>> Handled-By : Thomas Gleixner <tglx@linutronix.de>
>> Status     : problem is being debugged
>=20
> The BUG_ON() was replaced by a warning printk(). The BUG_ON() exposed=
 a
> problem with the SMT scheduler. See below.
>=20
>> Subject    : BUG: soft lockup detected on CPU#0
>>              NOHZ: local_softirq_pending 20  (SMT scheduler)
>> References : http://lkml.org/lkml/2007/2/20/257
>> Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
>> Handled-By : Thomas Gleixner <tglx@linutronix.de>
>>              Ingo Molnar <mingo@elte.hu>
>> Status     : problem is being debugged
>=20
> Patch available, not confirmed yet.
>=20

I can confirm that the bug is fixed (over 20 hours of testing should be=
 enough).

Huge thanks!

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
