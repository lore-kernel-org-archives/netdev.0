From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCHES] wireless: Update in-kernel orinoco driver
Date: Wed, 27 Oct 2004 12:05:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027020536.GF7925@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, Pavel Roskin <proski@gnu.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 02:12:00PM -0400, Dan Williams wrote:
> This series of 15 patches updates the in-kernel orinoco wireless drivers
> to the level of current upstream orinoco CVS (from sourceforge).  This
> level is "0.15rc2HEAD" as found in orinoco.h.
> 
> The basis for this patchset was:
> 
> upstream orinoco CVS from Mon, Oct 25
> kernel sources from linux-2.6.9.tar.bz2 + patch-2.6.10-rc1.bz2
> 
> This is a revival of an effort to get the drivers up-to-date from
> earlier this year in July.

This is a much better effort at splitting up the CVS differences than
the last one I saw, but there are still some problems.  In particular,
you've aimed the patch series at the CVS HEAD branch, which isn't what
we want to do.  We want to merge to mainline the "for_linus" branch ,
not HEAD.  The HEAD branch has a bunch of compatibility code so that
the code can work standalone against a range of kernels - this should
not be merge.  Also it has several things that are there because they
kind-of work, but are really too ugly to live and should not be merged
to mainline.

Some more specific comments coming, on the individual patches.

Oh, and CCing Pavel Roskin <proski@gnu.org> the other orinoco
maintainer would be a good idea, too.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
