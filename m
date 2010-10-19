From: Dave Airlie <airlied@gmail.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 14:52:32 +1000
Message-ID: <AANLkTi=oAeuz8ZxcOMpf=3MVY=WMt0BwHiGCUxO7OAEV@mail.gmail.com>
References: <201009161632.59210.arnd@arndb.de>
	<201010181742.06678.arnd@arndb.de>
	<20101018184346.GD27089@kroah.com>
	<AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com>
	<20101019004004.GB28380@kroah.com>
	<AANLkTi=ffaihP5-yNYFKAbAbX+XbRgWRXXfCZd4J3KwQ@mail.gmail.com>
	<20101019022413.GB30307@kroah.com>
	<AANLkTinv4VFpi=Jkc_5oyFgPbdLRg0ResJx9u9Puhm-7@mail.gmail.com>
	<1287459219.16971.352.camel@gandalf.stny.rr.com>
	<alpine.LNX.2.00.1010182342120.31740@banach.math.auburn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steven Rostedt <rostedt@goodmis.org>, Greg KH <greg@kroah.com>,
	codalist@telemann.coda.cs.cmu.edu, autofs@linux.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Arnd Bergmann <arnd@arndb.de>,
	Jan Harkes <jaharkes@cs.cmu.edu>, netdev@vger.kernel.org,
	Anders Larsen <al@alarsen.net>, linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	ksummit-2010-discuss@lists.linux-foundation.org,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Theodore Kilgore <kilgota@banach.math.auburn.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1010182342120.31740@banach.math.auburn.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I might be able to find some hardware still lying around here that uses an
> i810. Not sure unless I go hunting it. But I get the impression that if
> the kernel is a single-CPU kernel there is not any problem anyway? Don't
> distros offer a non-smp kernel as an installation option in case the user
> needs it? So in reality how big a problem is this?

Not anymore, which is my old point of making a fuss. Nowadays in the
modern distro world, we supply a single kernel that can at runtime
decide if its running on SMP or UP and rewrite the text section
appropriately with locks etc. Its like magic, and something like
marking drivers as BROKEN_ON_SMP at compile time is really wrong when
what you want now is a runtime warning if someone tries to hotplug a
CPU with a known iffy driver loaded or if someone tries to load the
driver when we are already in SMP mode.

Dave.
