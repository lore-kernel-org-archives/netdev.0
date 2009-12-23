From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 20:27:05 +0100
Message-ID: <877hsdcwza.fsf@basil.nowhere.org>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>
	<4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>
	<4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
	<20091223101340.GC20539@basil.fritz.box>
	<20091223185150.GA9587@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46240 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbZLWT1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 14:27:10 -0500
In-Reply-To: <20091223185150.GA9587@elte.hu> (Ingo Molnar's message of "Wed, 23 Dec 2009 19:51:50 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar <mingo@elte.hu> writes:

> Yes, there's (obviously) compatibility requirements and artifacts and past 
> mistakes (as with any software interface), but you need to admit it to 

Yes that's exactly what I meant. 

> yourself that your "virtualization is sloppy just like hardware" claim is just 

In my experience hardware is a lot less sloppy than software.
Imagine your latest CPU had as many regressions as 2.6.32 @)

I wish software and even VMs were as good.

> a cheap excuse to not do a proper job of interface engineering.

Past mistakes cannot be easily fixed. And undoubtedly even the new
shiny interfaces will have bugs and problems. Also the behaviour is
often not completely understood. Maybe it can be easier debugged with
fully available source, but even then it's hard to fix the old
software (or rather even if you can fix it deploy the fixes). In
that regard it's a lot like hardware.

I agree with you that this makes it important to design good
interfaces, but again realistically mistakes will be made
and they cannot be all fixed retroactively.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
