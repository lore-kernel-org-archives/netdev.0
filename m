From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH v2 -mm 4/9] netconsole: Add some useful tips to documentation
Date: Wed, 11 Jul 2007 11:35:03 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707111120120.10373@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710091941.23907.45658.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710094142.GM11115@waste.org> <200707101434.39938.jesper.juhl@gmail.com>
 <Pine.LNX.4.64.0707110256220.2445@cselinux1.cse.iitk.ac.in>
 <20070711042036.GR1011@tasint.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Juhl <jesper.juhl@gmail.com>,
	Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:47876 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbXGKFml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 01:42:41 -0400
In-Reply-To: <20070711042036.GR1011@tasint.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007, Joel Becker wrote:
> On Wed, Jul 11, 2007 at 03:40:22AM +0530, Satyam Sharma wrote:
> > IMHO something that mentions /proc/sys/kernel/printk would be better.
> > 
> > You don't need to have built with SysRq support for that, it's clearly
> > more flexible than the ignore_loglevel option and wouldn't require a
> > reboot either. I'll send out an updated patch shortly.
> 
> 	Why not dmesg -n?  We've been using that for years.  Or is there
> some extra change in /proc/sys/kernel/printk?

Yes, "dmesg -n" sounds the most straightforward. There are multiple ways
of course, for some reason I've always used /proc/sys/kernel/printk for
this (which has the extra "feature" that it accepts values greater than
8 too :-)

Satyam
