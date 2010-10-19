From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 22:38:13 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1010192237220.6879@pobox.suse.cz>
References: <201009161632.59210.arnd@arndb.de> <21406.1287512693@localhost> <20101019193735.GA4043@kroah.com> <201010192140.47433.oliver@neukum.org> <20101019202912.GA30133@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Oliver Neukum <oliver@neukum.org>, Jan Kara <jack@suse.cz>,
	Anders Larsen <al@alarsen.net>,
	dri-devel@lists.freedesktop.org,
	ksummit-2010-discuss@lists.linux-foundation.org,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	codalist@telemann.coda.cs.cmu.edu,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Ingo Molnar <mingo@elte.hu>, linux-media@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Arnd Bergmann <arnd@arndb.de>, autofs@linux.kernel.org,
	Jan Harkes <jaharkes@cs.cmu.edu>, Valdis.Kletnieks@vt.edu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48538 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381Ab0JSUiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 16:38:21 -0400
In-Reply-To: <20101019202912.GA30133@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Oct 2010, Greg KH wrote:

> > > > So no need to clean it up for multiprocessor support.
> > > > 
> > > > http://download.intel.com/design/chipsets/datashts/29067602.pdf
> > > > http://www.intel.com/design/chipsets/specupdt/29069403.pdf
> > > 
> > > Great, we can just drop all calls to lock_kernel() and the like in the
> > > driver and be done with it, right?
> > 
> > No,
> > 
> > you still need to switch off preemption.
> 
> Hm, how would you do that from within a driver?

preempt_disable()

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
