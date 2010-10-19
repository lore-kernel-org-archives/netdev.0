From: Greg KH <greg@kroah.com>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 17:40:04 -0700
Message-ID: <20101019004004.GB28380@kroah.com>
References: <201009161632.59210.arnd@arndb.de> <201010181742.06678.arnd@arndb.de> <20101018184346.GD27089@kroah.com> <AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, codalist@telemann.coda.cs.cmu.edu,
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
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2010 at 09:00:09AM +1000, Dave Airlie wrote:
> On Tue, Oct 19, 2010 at 4:43 AM, Greg KH <greg@kroah.com> wrote:
> > On Mon, Oct 18, 2010 at 05:42:06PM +0200, Arnd Bergmann wrote:
> >>
> >> Out of the remaining modules, I guess i810/i830, adfs, hpfs and ufs might end
> >> up not getting fixed at all, we can either mark them non-SMP or move them
> >> to drivers/staging once all the others are done.
> >
> > I recommend moving them to staging, and then retire them from there if
> > no one steps up to maintain them.
> 
> I think this sets a bad precedent, these drivers work fine. Removing
> BKL from them is hard, and involves finding and booting hw that
> developers don't have much time/interest in at the moment. Anyone who
> has access to the i810 hw and has time to work out the locking has
> more important things to be doing with modern hw, however it doesn't
> mean we should just drop support for old drivers because they don't
> have active maintainers. Removing the BKL from the kernel is a great
> goal, but breaking userspace ABI by removing drivers isn't.

Should we just restrict such drivers to only be able to build on UP
machines with preempt disabled so that the BKL could be safely removed
from them?

Or what other idea do you have as to what could be done here?

I do have access to this hardware, but its on an old single processor
laptop, so any work that it would take to help do this development,
really wouldn't be able to be tested to be valid at all.

thanks,

greg k-h
