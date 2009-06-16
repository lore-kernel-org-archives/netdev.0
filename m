From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Mon, 15 Jun 2009 21:21:14 -0700
Message-ID: <20090616042113.GA5680@tesla>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com> <20090615201934.GA12685@kroah.com> <20090615214735.GE23972@bombadil.infradead.org> <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>,
	"mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090616032034.GA17932-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2009 at 08:20:34PM -0700, Greg KH wrote:
> On Mon, Jun 15, 2009 at 10:10:11PM -0400, Luis R. Rodriguez wrote:
> > +     2.6.30  June 10, 2009 - 79 days
> > +     2.6.29  March 23, 2009 - 84 days
> > +     2.6.28  December 29, 2008 - 82 days
> > +     2.6.27  October 8, 2008 - 87 days
> > +     2.6.26  July 13, 2008 - 88 days
> > +     2.6.25  April 16, 2008 - 83 days
> > +     2.6.24  January 24, 2008 - 107 days
> > +     2.6.23  October 9, 2007 - 93 days
> > +     2.6.22  July 8, 2007 - 74 days
> > +     2.6.21  April 25, 2007 - 80 days
> >       2.6.20  February 4, 2007
> 
> Are you sure about those dates and the count of number of days?

I used this cheesy web app:

http://www.timeanddate.com/date/duration.html

So it could have told 42 for all answers I suppose and I wouldn't have known
the difference. BTW does your list count the ending date? That is from say
01-01-2009 to 01-02-2009 does it count 2 or 1? I set it to not count it.

> According to my "big spreadsheet of kernel releases", your day count is
> wrong...
> 
> I have:
> 
> release: v2.6.20  v2.6.21  v2.6.22  v2.6.23  v2.6.24  v2.6.25  v2.6.26  v2.6.27  v2.6.28  v2.6.29  v2.6.30
>  date:   02/04/07 04/25/07 07/08/07 10/09/07 01/24/08 04/16/08 07/13/08 10/09/08 12/24/08 03/23/09 06/09/09
> # Days:  68       81       75       94       108      83       88       88       76       89       78

I'll trust your big spreadsheet more and with it you actually get a nice
even 86.0 average.

Here is a new patch based on your spreadsheet info.

From: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] Documentation: add documentation summary for rc-series and merge window

This is losely based on previous discussions on linux-kernel [1][2].
Lets also refer people reading the stable rules to
Documentation/development-process/.

Also add the number of days it has taken between releases,
and provide the average for the last 10 releases: 86.0 days.

[1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
[2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2

Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---
 Documentation/development-process/2.Process |   92 ++++++++++++++++++++++++---
 Documentation/stable_kernel_rules.txt       |    5 ++
 2 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/Documentation/development-process/2.Process b/Documentation/development-process/2.Process
index d750321..668eb8f 100644
--- a/Documentation/development-process/2.Process
+++ b/Documentation/development-process/2.Process
@@ -7,20 +7,92 @@ course of one year, the kernel has since had to evolve a number of
 processes to keep development happening smoothly.  A solid understanding of
 how the process works is required in order to be an effective part of it.
 
+2.0:SUMMARY
+
+This section provides a brief summary of the kernel release rules.
+
+2.0.0: KERNEL RELEASE RULES
+
+Stable kernels are released when they are ready! This means there are
+absolutely no strict guidelines for sticking to specific dates for a
+kernel release.
+
+2.0.1: MERGE WINDOW
+
+The merge window opens up after the next stable kernel is released.
+The merge window is when maintainers of different subsystem send pull
+requests to Linus for code they have been queuing up for the next
+stable kernel. This is typically now done through respective
+foo-next-2.6.git trees where foo is your subsystem. Each maintainer
+queues up patches for the next kernel cycle in this foo-next-2.6.git
+tree. After the merge window the kernel is worked on through the
+rc-series of the kernel release. The merge window closes at the first
+rc-series release.
+
+After a maintainer has sent his pull request to Linus during the merge
+window no further new development will be accepted for that tree and
+as such it marks the closure of development for that subsystem for that
+kernel cycle. Developers wishing to target deadlines should simply work
+on their development without regards or consideration for inclusion to
+a specific kernel release. Once development is done it should simply be
+posted. If you insist on targeting a kernel release for deadlines you can
+try to be aware of the current rc cycle development and how soon it seems
+the next stable kernel release will be made. When Linus notes the last rc
+cycle released may be the last -- that is a good sign you should already
+have all your development done and merged in the respective development
+tree. If your code is not ready and merged into the respective maintainers
+tree prior to the announced last potential rc kernel release chances are
+you missed getting your code in for the next kernel merge window.
+Exemptions here are new drivers, covered below.
+
+2.0.2: RC-SERIES RULES
+
+Rules on what kind of patches are accepted after the merge window closes.
+These are patches targeted for the kernel rc-series of a kernel prior
+to its release.
+
+ - it must fix a reported regression
+ - if must fix a reported security hole
+ - if must fix a reported oops/kernel hang
+
+This means any small-non-fix code changes, although they might fix an issue,
+will not be accepted. If the patch in question is for a driver that has been
+around for more than a kernel release, then "small fixes" really can't be
+worth all that much. And "small fixes" may be small and "obvious" they
+definitely can regress.
+
+2.0.3 RC-SERIES NEW DRIVER EXEMPTION RULE
+
+The very first release a new driver (or filesystem) is special. New drivers
+are accepted during the rc series. Patches for the same driver then are
+also accepted during the same rc series of a kernel as well as fixes as it
+cannot regress as no previous kernels exists with it.
+
+Once drivers are upstream for one kernel release (say on 2.6.29) the target
+*goal* after the merge window of the next kernel (respectively this would be
+the 2.6.30 rc-series) is to address regressions. Kernel oops/hangs and security
+issues are obviously accepted but the point is these should have also been
+caught earlier as a general development goal. The rc-series focus should really
+be to address regressions.
 
 2.1: THE BIG PICTURE
 
 The kernel developers use a loosely time-based release process, with a new
-major kernel release happening every two or three months.  The recent
-release history looks like this:
-
-	2.6.26	July 13, 2008
-	2.6.25	April 16, 2008
-	2.6.24	January 24, 2008
-	2.6.23	October 9, 2007
-	2.6.22	July 8, 2007
-	2.6.21	April 25, 2007
-	2.6.20	February 4, 2007
+major kernel release happening about every two or three months. The current
+average time based on the last 10 releases is 86.0 days. The recent release
+history along with the number of days between each release looks like this:
+
+	2.6.30	June 10, 2009 - 78 days
+	2.6.29  March 23, 2009 - 89 days
+	2.6.28	December 29, 2008 - 76 days
+	2.6.27	October 8, 2008 - 88 days
+	2.6.26	July 13, 2008 - 88 days
+	2.6.25	April 16, 2008 - 83 days
+	2.6.24	January 24, 2008 - 108 days
+	2.6.23	October 9, 2007 - 94 days
+	2.6.22	July 8, 2007 - 75 days
+	2.6.21	April 25, 2007 - 81 days
+	2.6.20	February 4, 2007 - 68
 
 Every 2.6.x release is a major kernel release with new features, internal
 API changes, and more.  A typical 2.6 release can contain over 10,000
diff --git a/Documentation/stable_kernel_rules.txt b/Documentation/stable_kernel_rules.txt
index a452227..113e8c8 100644
--- a/Documentation/stable_kernel_rules.txt
+++ b/Documentation/stable_kernel_rules.txt
@@ -1,5 +1,10 @@
 Everything you ever wanted to know about Linux 2.6 -stable releases.
 
+For further details, such as stable kernel release schedules, rc-series
+policies and process of development please refer to:
+
+Documentation/development-process/
+
 Rules on what kind of patches are accepted, and which ones are not, into the
 "-stable" tree:
 
-- 
1.6.2.2.446.gfbdc0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
