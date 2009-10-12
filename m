From: Greg KH <gregkh@suse.de>
Subject: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
 2.6.32-rc3)
Date: Mon, 12 Oct 2009 08:09:11 -0700
Message-ID: <20091012150911.GB1656@suse.de>
References: <1255031298.4187.260.camel@mulgrave.site>
 <alpine.LFD.2.01.0910081252090.3432@localhost.localdomain>
 <alpine.LFD.2.01.0910081255510.3432@localhost.localdomain>
 <20091008210737.GD29181@mit.edu>
 <alpine.LFD.2.01.0910081410400.3432@localhost.localdomain>
 <20091009091538.GA4154@elte.hu>
 <1255097287.2934.21.camel@localhost.localdomain>
 <20091012130652.GB25464@elte.hu>
 <1255357148.2850.91.camel@localhost.localdomain>
 <20091012145453.GD4565@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091012145453.GD4565@elte.hu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adding David Miller and the wireless developers who had this idea as
well...

On Mon, Oct 12, 2009 at 04:54:53PM +0200, Ingo Molnar wrote:
> I think your interpretation is arbitrary - where did you get that ABI 
> rule from? I'm sure it cannot be from any of the drivers/staging/ 
> discussions on lkml, i've followed them quite closely. If 'has a messy 
> ABI' was the only requirement for drivers/staging/ then we could move 
> 90% of drivers/staging/ into drivers/ straight away - and that would be 
> counter-productive IMHO.

I agree with this, and the other points you raised that I snipped out.

> Sidenote, in fact i think we should expand on that: drivers/staging/ 
> should be used in the _other_ direction as well - to un-upstream stale 
> drivers that are abandoned and unused, in a gradual fashion. 'git mv' is 
> cheap.

Ok, this is about the 3rd or 4th time I've heard this, from totally
different people lately.  It seems that I'm the only one that has the
ability to drop drivers out of the kernel tree, which is a funny
situation :)

In thinking about this a lot more, I don't really mind it.  If people
want to push stuff out of "real" places in the kernel, into
drivers/staging/ and give the original authors and maintainers notice
about what is going on, _and_ provide a TODO file for what needs to
happen to get the code back into the main portion of the kernel tree,
then I'll be happy to help out with this and manage it.

I think a 6-9 month window (basically 3 kernel releases) should be
sufficient time to have a driver that has been in drivers/staging/ be
cleaned up enough to move back into the main kernel tree.  If not, it
could be easily dropped.

Any objections to this?

> Basically, drivers/staging/ gives us an excellent opportunity to 
> _increase_ the quality of drivers by applying stronger upstream 
> inclusion filters, without having to hurt users/developers in the 
> process. We just have to start using it that way as well.

I totally agree.  And so far, it does seem to be working well for this.
A number of companies have used it to successfully get their code into
the main kernel, as well as driving them to clean up their code better
to keep it from having to go into the staging tree.

thanks,

greg k-h
