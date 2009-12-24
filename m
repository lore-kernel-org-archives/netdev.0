From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 12:41:25 -0800
Message-ID: <adazl58yuiy.fsf@roland-alpha.cisco.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>
	<4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>
	<4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
	<20091223101340.GC20539@basil.fritz.box>
	<20091223185150.GA9587@elte.hu> <20091224065820.GE4490@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel\@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gleb Natapov <gleb@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091224065820.GE4490@redhat.com> (Gleb Natapov's message of
	"Thu, 24 Dec 2009 08:58:20 +0200")
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > > This is Linux virtualization, where _both_ the host and the guest source code 
 > > is fully known, and bugs (if any) can be found with a high degree of 

 > It may sound strange but Windows is very popular guest and last I
 > checked my HW there was no Windows sources there, but the answer to that
 > is to emulate HW as close as possible to real one and then closed source
 > guests will not have a reason to be upset.
 > 
 > > determinism. This is Linux where the players dont just vanish overnight, and 
 > > are expected to do a proper job.

And without even getting into closed/proprietary guests, virt is useful
for testing/developing/deploying many free OSes, eg FreeBSD, NetBSD,
OpenBSD, Hurd, <random research OS>, etc.  Not to mention just wanting a
stable [virtual] platform to run <old enterprise Linux distro> on.  So
having a virtual platform whose interface doesn't change very often or
very much has a lot of value at least in avoiding churn in guest OSes.

 - R.
