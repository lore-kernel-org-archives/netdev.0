From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 13:02:29 +0200
Message-ID: <87mynu5agq.fsf@basil.nowhere.org>
References: <47FEADCB.7070104@rtr.ca>
	<517f3f820804150254w491cdf85s28f1d15696db8d96@mail.gmail.com>
	<4804B5D5.4090404@davidnewall.com> <200804152251.51308.rjw@sisk.pl>
	<480565D3.6000100@davidnewall.com>
	<alpine.DEB.1.10.0804152042320.15483@asgard>
	<4805C199.2090702@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david@lang.hm, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	James Morris <jmorris@namei.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>,
	Stephen Clark <sclark46@earthlink.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Tilman Schmidt <tilman@imap.cc>, Valdis.Kletnieks@vt.edu,
	Mark Lord <lkml@rtr.ca>, David Miller <davem@davemloft.net>,
	jesper.juhl@gmail.com, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel <linux-kernel@vger.kernel.org>, git@vger.kernel.org,
	netdev@vger.kernel.org
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:30410 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569AbYDPLCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 07:02:49 -0400
In-Reply-To: <4805C199.2090702@davidnewall.com> (David Newall's message of "Wed, 16 Apr 2008 18:36:33 +0930")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Newall <davidn@davidnewall.com> writes:
>
> And I'd rather be able to see that that person introduced 100 bugs than
> to have no idea.   As has been said before, the current situation rewards
> people for sloppy work.

A common issue in the kernel is code who works with a wide 
range of hardware and firmware with varying quality. The original
code is written to spec but then in the real world the hardware
and firmware has all kinds of interesting quirks not quite
matching the spec that need additional updates to handle. I don't think
it's fair to say in this case the original developer was sloppy.

Then there is also code which is just hard to tune. Examples for this
are the CPU scheduler and the VM, but also other areas. They have to
handle a lot of different workloads with often subtle side effects.
Lots of people have put a lot of excellent work into tuning these
subsystems as users report issues with their workloads. Would you say
the original developers were sloppy? I don't think that would be a fair
description. Some problems are just hard and need many 
iterations to get right. And then often also the requirements change over 
time and need further updates.

There are more such examples in kernel.

Grading programers is a hard problem and I don't think the software
industry has really solved it so far, even though there was a lot of
effort trying to do it over several decades. I doubt it will be solved
for the Linux kernel either.

-Andi
