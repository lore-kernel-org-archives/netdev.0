From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
 2.6.32-rc3)
Date: Wed, 14 Oct 2009 21:00:49 +0200 (CEST)
Message-ID: <tkrat.88ac5cebebbd9689@s5r6.in-berlin.de>
References: <1255357148.2850.91.camel@localhost.localdomain>
 <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de>
 <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de>
 <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com>
 <20091014044519.GA19199@suse.de> <1255497575.1851.16.camel@Joe-Laptop.home>
 <20091014063308.GE784@elte.hu> <4AD60FF9.40200@s5r6.in-berlin.de>
 <20091014183657.GB5133@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=us-ascii
Cc: Joe Perches <joe@perches.com>, Greg KH <gregkh@suse.de>,
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
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20091014183657.GB5133@elte.hu>
Content-Disposition: INLINE
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 Oct, Ingo Molnar wrote:
> * Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:
>> How well do "git am", "quilt import" and friends cope with ever 
>> changing directories?

[Perhaps the -p option does the trick.  And git-am could be done on a
temporary branch from before the move of the files.]

> Once a driver is in a tree it's in Git and git mv is easy. People 
> working with Linux better familiarize themselves with Git workflow - the 
> sooner the better.

Even if author and committer both work with git, they often use e-mail
to transfer patches.

> If it's not in tree then it will adopt to whatever layout there is once 
> it gets into Greg's tree.

Many "good" drivers will start as "ugly" or "bad" ones.

>> How about using drivers/staging/this_driver/TODO and (or) its Kconfig 
>> help text to leave a note about the plans for this driver?
> 
> Well, the answer is obvious i think. Tell me, at a glance, if you see a 
> patch on lkml, which one is for a staging driver to be obsoleted, and 
> which one is the one going upstream real soon? The patches say:
> 
>  +++ a/drivers/staging/foo/x.c
> 
>  +++ a/drivers/staging/bar/y.c
> 
> Then tell me the same at a glance if you see patches for:
> 
>  +++ a/drivers/staging/wip/x.c
> 
>  +++ a/drivers/staging/bad/y.c

Does this information matter much?

What's more interesting is whether development activity will _lead_ to a
driver being moved from bad or ugly to good.
-- 
Stefan Richter
-=====-==--= =-=- -===-
http://arcgraph.de/sr/


