From: Neil Brown <neilb@suse.de>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 13:50:43 +1100
Message-ID: <18235.46083.293604.560507__11868.5755682693$1195095102$gmane$org@notabene.brown>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu>
	<20071113085514.3414aa52.rdunlap@xenotime.net>
	<20071114140847.GA11489@elte.hu>
	<20071114093820.ff3ad8f9.rdunlap@xenotime.net>
	<20071114182351.GI14254@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56013 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755973AbXKOCvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 21:51:04 -0500
In-Reply-To: message from J. Bruce Fields on Wednesday November 14
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday November 14, bfields@fieldses.org wrote:
> On Wed, Nov 14, 2007 at 09:38:20AM -0800, Randy Dunlap wrote:
> > On Wed, 14 Nov 2007 15:08:47 +0100 Ingo Molnar wrote:
> > > so please stop this "too busy and too noisy" nonsense already. It was 
> > > nonsense 10 years ago and it's nonsense today. In 10 years the kernel 
> > > grew from a 1 million lines codebase to an 8 million lines codebase, so 
> > > what? Deal with it and be intelligent about filtering your information 
> > > influx instead of imposing a hard pre-filtering criteria that restricts 
> > > intelligent processing of information.
> > 
> > So you have a preferred method of handling email.  Please don't
> > force it on the rest of us.
> 
> I'd be curious for any pointers on tools, actually.  I "read" (ok, skim)
> lkml but still overlook relevant bug reports occasionally.
> (Fortunately, between Trond and Andrew and others forwarding things it's
> not actually a problem, but I'm still curious).

Virtual Folders.

I use VM mode in EMACS, but I believe some other mail readers have the
same functionality.
I have a virtual folder called "nfs" which shows me all mail in my
inbox which has the string 'nfs' or 'lockd' in a To, Cc, or Subject
field.  When I visit that folder, I see all mail about nfs, whether it
was sent to me personally, or to a relevant list, or to lkml.

Admittedly if someone doesn't bother to choose a meaningful Subject,
then I might miss that.  I think this mostly happens when Andrew sends
a "-mm" announcement, asked people to change the subject line when
following up, and someone follows up without changing the subject line
and say "NFS doesn't work any more".

I have another virtual folder which matches "md" and "raid" and
"mdadm" in any header (so when the people from coraid.com talk about
ATA over Ethernet, that gets badly filed, but it is a small cost).

Then I have the "bkernel" (boring kernel) folder for all mail from
lkml that doesn't mention nfs or raid or md, and isn't from or to
me.  That folder I skim every week or so and just read the juicy
debates and look for interesting tidbits from interesting people -
then delete the whole folder, mostly unread.

I don't think I could cope with mail without virtual folders.

NeilBrown
