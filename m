From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.29-rc6: Reported regressions from 2.6.28
Date: Tue, 3 Mar 2009 14:45:13 -0500
Message-ID: <20090303194513.GA10548@infradead.org>
References: <GVhknozYwrL.A.hiC.rozoJB@chimera> <20090303193609.GE27178@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090303193609.GE27178@atrey.karlin.mff.cuni.cz>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 03, 2009 at 08:36:10PM +0100, Jan Kara wrote:
>   Hi,
> 
> > Unresolved regressions
> > ----------------------
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12551
> > Subject		: end_request: I/O error, dev cciss/c0d0, sector 87435720
> > Submitter	: Ralf Hildebrandt <ralf.hildebrandt@charite.de>
> > Date		: 2009-01-27 06:51 (28 days old)
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12497
> > Subject		: new barrier warnings in 2.6.29-rc1
> > Submitter	: Christoph Hellwig <hch@lst.de>
> > Date		: 2009-01-12 15:46 (43 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123177528217154&w=4
> > Handled-By	: Jens Axboe <jens.axboe@oracle.com>
>   I've just noticed that the above two reports are probably the same bug...
> Just that we don't duplicate the effort.

At least on the XFS side it's fixed now.  The block layer gets the
initial detection right without warning, and a patch to fix the
unconditional cache flush on unmount is on it's way.
