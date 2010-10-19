From: Greg KH <greg@kroah.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 12:37:35 -0700
Message-ID: <20101019193735.GA4043@kroah.com>
References: <201009161632.59210.arnd@arndb.de>
 <201010181742.06678.arnd@arndb.de>
 <20101018184346.GD27089@kroah.com>
 <AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com>
 <20101019004004.GB28380@kroah.com>
 <21406.1287512693@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Airlie <airlied@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
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
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <21406.1287512693@localhost>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 02:24:53PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 18 Oct 2010 17:40:04 PDT, Greg KH said:
> 
> > I do have access to this hardware, but its on an old single processor
> > laptop, so any work that it would take to help do this development,
> > really wouldn't be able to be tested to be valid at all.
> 
> The i810 is a graphics chipset embedded on the memory controller, which
> was designed for the Intel Pentium II, Pentium III, and Celeron CPUs.  Page 8
> of the datasheet specifically says:
> 
> Processor/Host Bus Support
> - Optimized for the Intel Pentium II processor, Intel Pentium III processor, and Intel
> CeleronTM processor
> - Supports processor 370-Pin Socket and SC242
> connectors
> - Supports 32-Bit System Bus Addressing
> - 4 deep in-order queue; 4 or 1 deep request queue
> - Supports Uni-processor systems only
> 
> So no need to clean it up for multiprocessor support.
> 
> http://download.intel.com/design/chipsets/datashts/29067602.pdf
> http://www.intel.com/design/chipsets/specupdt/29069403.pdf

Great, we can just drop all calls to lock_kernel() and the like in the
driver and be done with it, right?

thanks,

greg k-h
