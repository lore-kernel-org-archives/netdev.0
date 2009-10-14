From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Wed, 14 Oct 2009 08:33:08 +0200
Message-ID: <20091014063308.GE784@elte.hu>
References: <1255097287.2934.21.camel@localhost.localdomain> <20091012130652.GB25464@elte.hu> <1255357148.2850.91.camel@localhost.localdomain> <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de> <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de> <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com> <20091014044519.GA19199@suse.de> <1255497575.1851.16.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, "Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1255497575.1851.16.camel@Joe-Laptop.home>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Joe Perches <joe@perches.com> wrote:

> On Tue, 2009-10-13 at 21:45 -0700, Greg KH wrote:
> > How about when it was scheduled to be removed, we put it in staging and
> > I'll add it to my announcements about the staging tree every release?
> > Unless you can think of a better way?
> 
> staging/to_be_removed_unless_fixed_by/v.x.y ?

Yes, that's a real worry. Some time ago i suggested:

  drivers/staging/good/
  drivers/staging/bad/
  drivers/staging/ugly/

 good:  drivers that are to go upstream in the next cycle 
 bad:   outgoing drivers being obsoleted or abandoned
 ugly:  incoming messy drivers with active developers

The messaging of this looks nice and the names are short and obvious.

An added benefit is that this kind of separation makes it easy for 
people interested in drivers/staging to follow the 'status' of drivers. 
Once stuff goes into 'good' a different kind of review is needed than if 
a driver goes into 'ugly'.

The main disadvantage would be the PR angle: putting new drivers into a 
path named 'ugly'. Not something you want to put into a quarterly status 
report, right? If we put drivers/staging/ugly/ drivers into 
drivers/staging/ itself, we'd solve that problem. I.e. we'd keep the 
current scheme, but we'd also add drivers/staging/good/ and 
drivers/staging/bad/ as two extra stages for incoming and outgoing 
drivers.

A third version would be a more neutral name:

  drivers/staging/incoming/
  drivers/staging/outgoing/

I think it has many advantages, but (of course!) it all depends on 
whether Greg wants to have any separation like this.

	Ingo
