From: Greg KH <greg@kroah.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 11:43:46 -0700
Message-ID: <20101018184346.GD27089@kroah.com>
References: <201009161632.59210.arnd@arndb.de>
 <201010181742.06678.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: codalist@TELEMANN.coda.cs.cmu.edu,
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010181742.06678.arnd@arndb.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 18, 2010 at 05:42:06PM +0200, Arnd Bergmann wrote:
> 
> Out of the remaining modules, I guess i810/i830, adfs, hpfs and ufs might end
> up not getting fixed at all, we can either mark them non-SMP or move them
> to drivers/staging once all the others are done.

I recommend moving them to staging, and then retire them from there if
no one steps up to maintain them.

thanks,

greg k-h
