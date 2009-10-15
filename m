From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Thu, 15 Oct 2009 08:03:03 +0200
Message-ID: <20091015060303.GA32415@elte.hu>
References: <20091012150911.GB1656@suse.de> <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de> <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com> <20091014044519.GA19199@suse.de> <1255497575.1851.16.camel@Joe-Laptop.home> <20091014063308.GE784@elte.hu> <4AD60FF9.40200@s5r6.in-berlin.de> <20091014183657.GB5133@elte.hu> <tkrat.88ac5cebebbd9689@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:36795 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933619AbZJOGEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:04:01 -0400
Content-Disposition: inline
In-Reply-To: <tkrat.88ac5cebebbd9689@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Stefan Richter <stefanr@s5r6.in-berlin.de> wrote:

> > Well, the answer is obvious i think. Tell me, at a glance, if you 
> > see a patch on lkml, which one is for a staging driver to be 
> > obsoleted, and which one is the one going upstream real soon? The 
> > patches say:
> > 
> >  +++ a/drivers/staging/foo/x.c
> > 
> >  +++ a/drivers/staging/bar/y.c
> > 
> > Then tell me the same at a glance if you see patches for:
> > 
> >  +++ a/drivers/staging/wip/x.c
> > 
> >  +++ a/drivers/staging/bad/y.c
> 
> Does this information matter much?

Yes. You might not appreciate it as you are active in a relatively 
narrow field (so all patches in your world have an 'obvious' place) - 
but i for example take most of the context of a change from the email 
itself and the more self-descriptive it is, the better. I would be more 
likely to review work-in-progress patches while not bother about 
obsolete drivers on the way out. YMMV.

> What's more interesting is whether development activity will _lead_ to 
> a driver being moved from bad or ugly to good.

... a prerequisite of which is for more developers to be accutely aware 
of in what state a driver is.

Anyway ... it's all up to Greg and he indicated that he wants the 
simplest structure, which is fair enough.

	Ingo
