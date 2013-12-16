From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Mon, 16 Dec 2013 13:21:32 -0800
Message-ID: <20131216212132.GB8946@xanatos>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com>
 <20131202214205.GA26175@kroah.com>
 <52A166CB.4020508@pobox.com>
 <20131206152512.GA23212@kroah.com>
 <52A29FB5.2010108@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	netdev@vger.kernel.org
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46014 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617Ab3LPVVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 16:21:33 -0500
Content-Disposition: inline
In-Reply-To: <52A29FB5.2010108@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 11:10:29PM -0500, Mark Lord wrote:
> On 13-12-06 10:25 AM, Greg Kroah-Hartman wrote:
> > On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> >> On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> >>> On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> >>>> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> >>>>
> >>>>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
> >>>>
> >>>> are available in the git repository at:
> >>>>
> >>>>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> >>>
> >>> Pulled and pushed out, thanks.
> >>
> >> Did this commit make it into linux-3.12.3 ?
> >
> > No, it's not there yet, as it's not in Linus's tree yet, give me a chance...
> 
> Okay, good to see it moving along.
> 
> I asked about 3.12.3, because something new in that release broke
> Davids workaround for me here.
> 
> But I'm with the rest of you: let's let what's in the pipeline
> make it out there (3.12.4 ?) and then I'll retest and repatch that
> if necessary to make things work here again.

Hi Mark,

3.13-rc4 is out now, and it includes David's work-around.  Can you
please test with that kernel and confirm it fixes your issues with the
USB ethernet adapter?

Thanks,
Sarah Sharp
