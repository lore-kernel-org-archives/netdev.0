From: David Miller <davem@davemloft.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 15:17:47 -0700 (PDT)
Message-ID: <20060822.151747.56047759.davem@davemloft.net>
References: <1156281182.2476.63.camel@entropy>
	<20060822143747.68acaf99.rdunlap@xenotime.net>
	<20060822150144.058d9052.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, nmiell@comcast.net, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43697
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751279AbWHVWRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 18:17:35 -0400
To: akpm@osdl.org
In-Reply-To: <20060822150144.058d9052.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Tue, 22 Aug 2006 15:01:44 -0700

> If there _is_ something wrong with kqueue then let us identify those
> weaknesses and then diverge.

Evgeniy already enumerated this, both on his web site and in the
current thread.

Unlike some people seem to imply, Evgeniy did research all the other
implementations of event queueing out there, including kqueue.
He took the best of that survey, adding some of his own ideas,
and that's what kevent is.  It's not like he's some kind of
charlatan and made arbitrary decisions in his design without any
regard for what's out there already.

Again, the proof is in the pudding, he wrote applications against his
interfaces and tested them.  That's what people need to really do if
they want to judge his interface, try to write programs against it and
report back any problems they run into.
