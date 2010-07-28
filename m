From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename  regression
Date: Wed, 28 Jul 2010 00:57:16 -0700
Message-ID: <m1ocdsox7n.fsf@fess.ebiederm.org>
References: <1279822828.12439.24.camel@jlt3.sipsolutions.net>
	<20100722182827.GA12821@suse.de>
	<1279823801.12439.31.camel@jlt3.sipsolutions.net>
	<20100722185449.GB528@suse.de> <m1eievugon.fsf@fess.ebiederm.org>
	<20100726180941.GB4883@kroah.com>
	<AANLkTincg-0-h1aqW4A=z6A+HTbOfkCCWKDD18ZUEGSn@mail.gmail.com>
	<20100727134904.GA4994@kroah.com> <m14ofkiybo.fsf@fess.ebiederm.org>
	<AANLkTi=ttTjec7RjUZRM9v5WtLEYNPtH9L2qx8Js1WCT@mail.gmail.com>
	<20100727183624.GB30363@kroah.com> <m1zkxcg3xe.fsf@fess.ebiederm.org>
	<AANLkTi=LB7qV3S1miOocpQCtCaxhqJsLS51UDcnGjK+u@mail.gmail.com>
	<m1aapcejf5.fsf@fess.ebiederm.org>
	<AANLkTimA9Mo0B6MOn31KQ=L+raeCUg6eH3Mqf=vB5AYz@mail.gmail.com>
	<m1aapcqje4.fsf@fess.ebiederm.org>
	<AANLkTikoLQMH5LZCgKmQivTrtvtCf8oksk-HwBQQ+Tte@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44123 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab0G1H5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 03:57:33 -0400
In-Reply-To: <AANLkTikoLQMH5LZCgKmQivTrtvtCf8oksk-HwBQQ+Tte@mail.gmail.com> (Kay Sievers's message of "Wed\, 28 Jul 2010 07\:26\:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kay Sievers <kay.sievers@vrfy.org> writes:

> Yeah, but most of these things we should have fixed over the last
> years. There is no single WAIT_FOR instruction left in udev rules. :)

Last time I looked there were quite a few attributes that were still
getting created late.  I would not be surprised if the common case
works fine, but I know of a least one and I think a couple of weird
cases that still have to do unpleasant things.

Still that is a project for another time.


>> At the subsystem level bus devices look better.
>> At the individual device level bus devices stacked on bus devices
>> appear to be a namespace disaster.
>
> They are usually created by the same code, in many cases by the same
> drivers, and have not been a real problem so far. As you said, network
> devices are special here, because of the ability to rename them from
> userspace.
>
> At some time in the future, when buses and classes are merged, I
> expect stuff can just set a flag to have a 'glue dir' created or not.
>
> For now 'glue dirs' are limited to be created between a bus and a
> class device. It could possibly be extended to be created between
> classes of different types to handle issues like this.

Sounds like a plan.  And now I'm off on vacation.

Have a good one.

Eric
