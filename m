From: Greg KH <greg@kroah.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Thu, 8 Feb 2007 16:52:11 -0800
Message-ID: <20070209005211.GD30794@kroah.com>
References: <200702080400.l1840lFd002314@hera.kernel.org> <45CB1AE6.9020707@garzik.org> <20070208074130.29df585f@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:49438 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945946AbXBIAxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 19:53:20 -0500
Content-Disposition: inline
In-Reply-To: <20070208074130.29df585f@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 07:41:30AM -0800, Stephen Hemminger wrote:
> On Thu, 08 Feb 2007 07:43:18 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
> > Linux Kernel Mailing List wrote:
> > > Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=43cb76d91ee85f579a69d42bc8efc08bac560278
> > > Commit:     43cb76d91ee85f579a69d42bc8efc08bac560278
> > > Parent:     2943ecf2ed32632473c06f1975db47a7aa98c10f
> > > Author:     Greg Kroah-Hartman <gregkh@suse.de>
> > > AuthorDate: Tue Apr 9 12:14:34 2002 -0700
> > > Committer:  Greg Kroah-Hartman <gregkh@suse.de>
> > > CommitDate: Wed Feb 7 10:37:11 2007 -0800
> > > 
> > >     Network: convert network devices to use struct device instead of class_device
> > >     
> > >     This lets the network core have the ability to handle suspend/resume
> > >     issues, if it wants to.
> 
> It fixes a non-problem. I would like to see the network core suspend/resume
> proposal as well. Last time I examined doing network core suspend help,
> the problem was that the physical device suspend was called before the
> class device. It is not clear how this change would help.

Now the real device of the network device (ethX and such) will be called
first.  If not, something's wrong...

thanks,

greg k-h
