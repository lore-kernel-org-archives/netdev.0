From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: [PATCH] Drivers: isdn: gigaset: checkpatch cleanup
Date: Wed, 31 Dec 2014 10:32:38 -0800
Message-ID: <20141231183238.GA2658@hudson.localdomain>
References: <1420047298-7798-1-git-send-email-baspeters93@gmail.com>
 <20141231174936.GB1922@hudson.localdomain>
 <CAOgR63d6FNxntkBaSWM6ozibYGzajt07OLiM2XcszJarSaGX6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOgR63d6FNxntkBaSWM6ozibYGzajt07OLiM2XcszJarSaGX6A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bas,

On Wed, Dec 31, 2014 at 07:04:30PM +0100, Bas Peters wrote:
> 2014-12-31 18:49 GMT+01:00 Jeremiah Mahler <jmmahler@gmail.com>:
> > Bas,
> >
> > On Wed, Dec 31, 2014 at 06:34:58PM +0100, Bas Peters wrote:
> >> Fixed many checkpatch.pl complaints, ranging from whitespace issues to
> >> reportedly deprecated function and macro usage.
> >>
> > One patch should fix one type of problem.  This needs to be broken up
> > in to individual patches.
> >
> >> I have not been able to test the code as I do not have access to the
> >> hardware but since no new features were really added I don't think that
> >> should pose a problem.
> >>
> >> There are still some checkpatch complaints, particularly concerning
> >> potentially unnecessary 'out of memory' messages. I will provide patches
> >> for these complaints when I figure out the reason behind it and what to
> >> do about it.
> >>
> >> NOTE: This is my first patch (ever). I have attempted to follow all
> >> guidelines provided, but I probably will have missed some. If you have
> >> any comments regarding the quality of this patch or suggestions as to
> >> what I could do better in the future, please let me know.
> >>
> > You are ambitious.  I would suggest trying a smaller patch first to
> > make sure you are doing everything right.
> 
> With 'smaller patch', do you refer to less files at once or a different driver?
> Is it generally preferred to send patches that relate to the same
> issue (changes to a single file,
> grouping of patches to tackle the same issue, such as conversion of a
> specific function) over
> patch(sets) that deal with an entire driver?
> 
> Thanks for the advice!
> 

Your patch should solve one problem.  This could result in a single file
being changed or many being changed.  For simple checkpatch errors I
usually group all of one type of error for one file as a patch.

The goal is to make it easy to review.  If you fixed 10 different types
of issues in one patch it would difficult to review because I would have
to remember whether the change I am looking at was for issue 3 or 8 or
5 or ...?

Also, if the code had a bug, a bisect will point me to the patch.  But
then I have to figure out which of the 10 changes in that one patch
created the problem.  This is much easier if there was only one change
in that one patch.

Also have a look at Documentation/SubmittingPatches.  Specifically the
section "Separate your changes".

> >
> >> Signed-off-by: Bas Peters <baspeters93@gmail.com>
> >> ---
> >>  drivers/isdn/gigaset/asyncdata.c   |  9 +++--
> >>  drivers/isdn/gigaset/bas-gigaset.c | 80 ++++++++++++++++++++------------------
> >>  drivers/isdn/gigaset/capi.c        |  5 ++-
> >>  drivers/isdn/gigaset/common.c      |  8 ++--
> >>  drivers/isdn/gigaset/ev-layer.c    | 38 +++++++++++-------
> >>  drivers/isdn/gigaset/gigaset.h     |  4 +-
> >>  drivers/isdn/gigaset/i4l.c         | 12 +++---
> >>  drivers/isdn/gigaset/interface.c   | 10 ++---
> >>  drivers/isdn/gigaset/isocdata.c    |  3 ++
> >>  drivers/isdn/gigaset/proc.c        | 17 +++++---
> >>  drivers/isdn/gigaset/usb-gigaset.c | 46 +++++++++++++++-------
> >>  11 files changed, 141 insertions(+), 91 deletions(-)
> >>
> >> diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
> > [...]
> >
> > --
> > - Jeremiah Mahler

-- 
- Jeremiah Mahler
