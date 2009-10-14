From: Greg KH <gregkh@suse.de>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
 2.6.32-rc3)
Date: Wed, 14 Oct 2009 12:11:36 -0700
Message-ID: <20091014191136.GA4874@suse.de>
References: <20091012130652.GB25464@elte.hu>
 <1255357148.2850.91.camel@localhost.localdomain>
 <20091012145453.GD4565@elte.hu>
 <20091012150911.GB1656@suse.de>
 <20091012154244.GA13323@elte.hu>
 <20091012232429.GA24254@suse.de>
 <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com>
 <20091014044519.GA19199@suse.de>
 <1255497575.1851.16.camel@Joe-Laptop.home>
 <20091014063308.GE784@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50618 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758477AbZJNTQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 15:16:31 -0400
Content-Disposition: inline
In-Reply-To: <20091014063308.GE784@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 08:33:08AM +0200, Ingo Molnar wrote:
> 
> * Joe Perches <joe@perches.com> wrote:
> 
> > On Tue, 2009-10-13 at 21:45 -0700, Greg KH wrote:
> > > How about when it was scheduled to be removed, we put it in staging and
> > > I'll add it to my announcements about the staging tree every release?
> > > Unless you can think of a better way?
> > 
> > staging/to_be_removed_unless_fixed_by/v.x.y ?
> 
> Yes, that's a real worry. Some time ago i suggested:
> 
>   drivers/staging/good/
>   drivers/staging/bad/
>   drivers/staging/ugly/
> 
>  good:  drivers that are to go upstream in the next cycle 
>  bad:   outgoing drivers being obsoleted or abandoned
>  ugly:  incoming messy drivers with active developers
> 
> The messaging of this looks nice and the names are short and obvious.

Yeah, but they make my life much harder than it needs to be.

I'd prefer to stick with the directory naming scheme we have today, it
seems to work well so far.

thanks,

greg k-h
