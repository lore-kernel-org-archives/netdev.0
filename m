From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 04/13] e1000e: cleanup checkpatch PREFER_PR_LEVEL
 warning
Date: Fri, 24 Aug 2012 15:43:46 -0700
Message-ID: <1345848226.32359.18.camel@joe2Laptop>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345730504.16471.3.camel@joe2Laptop> <1345831348.32359.8.camel@joe2Laptop>
	 <1345843164.3613.9.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41338 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751879Ab2HXWnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 18:43:47 -0400
In-Reply-To: <1345843164.3613.9.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 14:19 -0700, Jeff Kirsher wrote:
> On Fri, 2012-08-24 at 11:02 -0700, Joe Perches wrote:
> > On Thu, 2012-08-23 at 07:01 -0700, Joe Perches wrote:
> > > On Thu, 2012-08-23 at 02:56 -0700, Jeff Kirsher wrote:
> > > > From: Bruce Allan <bruce.w.allan@intel.com>
> > > > 
> > > > checkpatch warning: Prefer pr_info(... to printk(KERN_INFO, ...
> > > []
> > > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> > > []
> > > > @@ -4330,9 +4330,8 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
> > > >  	u32 ctrl = er32(CTRL);
> > > >  
> > > >  	/* Link status message must follow this format for user tools */
> > > > -	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> > > > -		adapter->netdev->name,
> > > > -		adapter->link_speed,
> > > > +	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
> > > > +		adapter->netdev->name, adapter->link_speed,
> > > >  		adapter->link_duplex == FULL_DUPLEX ? "Full" : "Half",
> > > >  		(ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE) ? "Rx/Tx" :
> > > >  		(ctrl & E1000_CTRL_RFCE) ? "Rx" :
[]
> > The comment above this change (and the other) reads
> > 
> >   	/* Link status message must follow this format for user tools */
> > 
> > This file already uses #define pr_fmt(fmt) KBUILD_MODNAME...
> > With this patch, the output form changes to use 2 prefixes.
> > 
> > Is that really desired?  Probably not.
> > 
> > If the comments are old and don't apply any more, they
> > should be removed.
> > 
> Bruce really should answer this since this is his patch and there was a
> reason why he made the change.  My guess was the current output was
> providing incorrect or mis-leading information.

My guess is he was just shutting up checkpatch and
didn't notice the newly doubled prefix.

happy weekend...
