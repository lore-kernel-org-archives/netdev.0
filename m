From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [Bonding-announce] [PATCH SET][bonding] cleanup
Date: Thu, 25 Sep 2003 17:13:00 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030925211259.GA59653@calma.pair.com>
References: <shmulik.hen@intel.com> <200309252011.53960.shmulik.hen@intel.com> <200309251733.h8PHXWpV013559@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shmulik.hen@intel.com, "Chad N. Tindel" <chad@tindel.net>,
	bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	"Noam, Amir" <amir.noam@intel.com>,
	"Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
	"Noam, Marom" <noam.marom@intel.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200309251733.h8PHXWpV013559@death.ibm.com>
List-Id: netdev.vger.kernel.org

> >>	I was going to add it on to the end of the clean up set, but
> >> if you want to do it, go ahead.  Nobody seems to have objected to
> >> removing the _OLD stuff, which I view as a good thing.
> 
> 	My thinking here is that any ifenslave old enough (two years
> or more) to still be using the OLD ioctl values is unlikely to work
> with the current kernel driver, and if somebody did try it, it's
> better to have the call fail outright than perform weird and
> mysterious rituals in kernel memory.  I have trouble envisioning an
> scenario where a user would be using the latest 2.4.23 kernel, but an
> ifenslave from, what, 2.2.15? 2.4.5? or so.

I was specifically told by David Miller that we are not to break binary
compatibility within a 2.4 release.  Such things had to wait until 2.5 
or later.  We can not require a user to upgrade their ifenslave within a 2.4
series kernel just to keep using the same functionality they were using in 
2.4.1.  Obviously we can require them to upgrade in order to keep using
new functionality.  So the _OLD stuff needs to stay in the 2.4 kernel.  If
this was brought up in an earlier thread, then I just missed it.

Chad
