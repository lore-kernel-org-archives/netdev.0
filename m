From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 20:02:25 -0700
Message-ID: <1345777345.16471.18.camel@joe2Laptop>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120823111622.GC2238@netboy.at.omicron.at>
	 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
	 <20120823175335.GB2192@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35524 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750924Ab2HXDC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 23:02:27 -0400
In-Reply-To: <20120823175335.GB2192@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 19:53 +0200, Richard Cochran wrote:
> On Thu, Aug 23, 2012 at 04:22:02PM +0000, Vick, Matthew wrote:
> 
> > > >  #ifdef CONFIG_IGB_PTP
> > > > -static int igb_ethtool_get_ts_info(struct net_device *dev,
> > > > +static int igb_get_ts_info(struct net_device *dev,
> > > 
> > > I like the old name better.
> > 
> > The old name is out of the coding style of igb. Every other
> > function is igb_get_* or igb_set_*, with the exception of
> > igb_ethtool_begin and igb_ethtool_complete.

> No, just leave the names alone, and keep the functions where they
> are. It is just churn.
> 
> One of the most useful ways to understand code (at least for me) is to
> use git blame. It tells you when code was added, what the reason was,
> and how the change looks in context. By moving and renaming willy
> nilly, you are obscuring this valuable information.

[]

> > I'm sorry you feel like this patch doesn't improve the driver.
> > The goal is code cleanup and consistency, both of which I
> > consider to be driver improvements and is why I made the patches. 
> 
> But the code wasn't dirty in the first place. It doesn't need this
> "cleaning." This series undoes the inline-able functions for no good
> reason. As far as ixgbe goes, this driver came first, so you might as
> well be making *that* driver consistent with this one.

I disagree with Richard.

Improving code clarity and consistency isn't churn.

Old code isn't necessarily the best code, nor should
necessarily old code be a required guide for new code.

The most valuable form of code is the current one,
not any antecedent version.

People that need to wade through old crud to blame
someone still can.
