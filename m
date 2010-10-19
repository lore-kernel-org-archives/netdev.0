From: Greg KH <greg@kroah.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 13:29:12 -0700
Message-ID: <20101019202912.GA30133@kroah.com>
References: <201009161632.59210.arnd@arndb.de>
 <21406.1287512693@localhost>
 <20101019193735.GA4043@kroah.com>
 <201010192140.47433.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu, Dave Airlie <airlied@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:49484 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757273Ab0JSUaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 16:30:01 -0400
Content-Disposition: inline
In-Reply-To: <201010192140.47433.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 09:40:47PM +0200, Oliver Neukum wrote:
> Am Dienstag, 19. Oktober 2010, 21:37:35 schrieb Greg KH:
> > > So no need to clean it up for multiprocessor support.
> > > 
> > > http://download.intel.com/design/chipsets/datashts/29067602.pdf
> > > http://www.intel.com/design/chipsets/specupdt/29069403.pdf
> > 
> > Great, we can just drop all calls to lock_kernel() and the like in the
> > driver and be done with it, right?
> 
> No,
> 
> you still need to switch off preemption.

Hm, how would you do that from within a driver?

thanks,

greg k-h
