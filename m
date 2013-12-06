From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 09:29:47 -0800
Message-ID: <20131206172947.GA13222@kroah.com>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com>
 <20131202214205.GA26175@kroah.com>
 <52A166CB.4020508@pobox.com>
 <20131206170325.GA14254@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <mlord@pobox.com>, linux-usb@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56635 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757988Ab3LFR3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:29:48 -0500
Content-Disposition: inline
In-Reply-To: <20131206170325.GA14254@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 09:03:25AM -0800, Sarah Sharp wrote:
> On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> > On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> > > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> > >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> > >>
> > >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
> > >>
> > >> are available in the git repository at:
> > >>
> > >>
> > >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> > > 
> > > Pulled and pushed out, thanks.
> > 
> > Did this commit make it into linux-3.12.3 ?
> > 
> > I ask, because the NIC still locks up with that kernel,
> > and even with the patch I had been using from David Laight.
> > 
> > Reverting the change that originally broke it still works though.
> > Could we please get this reverted until such time as a reworked
> > patch can be prepared for it?
> 
> Greg, can you please revert David's patch (commit 35773dac5f86 from your
> usb-linus branch)?

Now reverted.

thanks,

greg k-h
