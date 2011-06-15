From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Wed, 15 Jun 2011 16:35:16 -0400
Message-ID: <20110615203516.GM21309@gospo.rdu.redhat.com>
References: <1306956602.32125.28.camel@Joe-Laptop> <1306957998.3076.18.camel@jtkirshe-MOBL1> <1306958478.32125.32.camel@Joe-Laptop> <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578Ab1FOUfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 16:35:24 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 11:38:43AM -0700, Jeff Kirsher wrote:
> On Wed, Jun 1, 2011 at 13:01, Joe Perches <joe@perches.com> wrote:
> > On Wed, 2011-06-01 at 12:53 -0700, Jeff Kirsher wrote:
> >> On Wed, 2011-06-01 at 12:30 -0700, Joe Perches wrote:
> >> > Does anyone still think moving files around in drivers/net
> >> > would be sensible and a suitable candidate for inclusion
> >> > in 3.1?
> >> > Here's what Jeffrey proposed:
> >> > http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
> >> > Here's what I proposed before that.
> >> > http://www.spinics.net/lists/netdev/msg149717.html
> >> I am over 90% done with the work and have been trying to finish up the
> >> patches so that I could get them out as an RFC here in the next week.
> >
> > Excellent, thanks.
> >
> 
> I thought for sure I would have finished what I have left by last
> weekend, but I keep getting interrupted.  (Blame it on the NHL stanley
> cup playoffs) :)
> 
> I have created a git tree on kernel.org with all the work that I have
> completed so far (see below).  This first stage of the move is only
> taking care of the drivers.  The next stage will move the networking
> core drivers (bridging, bonding, vlan, etc.) into drivers/net/sw.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-organize
> 
> I will send out all the patches as an RFC by the end of the week (for sure).
> 

My only complaint about this is that as expected we lose any history
that used to be there with the 'git log' command.  Of course 'git log
--follow' still works on individual files, but we lose the ability to
look at entire directories.

