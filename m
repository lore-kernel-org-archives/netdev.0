From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: Make --strict a default for files in
 drivers/net and net/
Date: Fri, 09 May 2014 14:44:12 -0700
Message-ID: <1399671852.2912.29.camel@joe-AO725>
References: <487acde009f61607863704e5dd9da7f151cf5be8.1399486274.git.joe@perches.com>
	 <20140509153748.e2467ab487404f07e818719e@freescale.com>
	 <1399668975.2912.14.camel@joe-AO725>
	 <20140509162914.8f8ac84b3a973820a21e5c2d@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andy Whitcroft <apw@canonical.com>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140509162914.8f8ac84b3a973820a21e5c2d@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-09 at 16:29 -0500, Kim Phillips wrote:
[]
> > > this isn't easily extensible/scalable to other subsystems, or
> > > say something like "all Freescale drivers."  Having it configurable
> > > in .checkpatch.conf might be a better solution, but I don't believe
> > > networking should be the only subsystem that can take advantage of
> > > the extra checkpatch CHECKs.
> > 
> > staging probably could too.
> 
> why call staging out to be subject to stricter checks than the rest
> of the kernel, when it's code that's _known_ to be non-compliant?

Staging is mostly a "play area sandbox" for people
that want to submit "my first kernel patch" and
GregKH seems to apply style-only patches like that.

> > > Can we enable --strict universally in the Linux kernel, maybe like
> > > so:?
> > 
> > I don't think that's appropriate (yet?).
> 
> why not?  checkpatch CHECKs seem reasonably stable AFAICT.

Several maintainers have their own style or don't
care at all about what indentation is used.

Several maintainers prefer stasis to what they
perceive as changes that are just whitespace noise.

> would an alternative option be to promote CHECKs like parentheses
> alignment to WARN status?

Probably not.

> > Try that with a per-file "wc -l" for checks per LOC
> 
> good point, that reinforces the statement back for networking :) :
> 
> {drivers/}net/ :            0.013 CHECKs per .[hc] file line
> everything else:            0.43  CHECKs per .[hc] file line
> no net, no drivers/staging: 0.38  CHECKs per .[hc] file line

yup. cheers, Joe
