From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/6] e1000: configure and read MDI settings
Date: Sat, 21 Jul 2012 16:37:46 +0100
Message-ID: <1342885066.11373.126.camel@deadeye.wl.decadent.org.uk>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
	  <1342820631-19738-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342826859.11373.123.camel@deadeye.wl.decadent.org.uk>
	 <alpine.WNT.2.00.1207201807470.14524@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Tushar Dave <tushar.n.dave@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16337 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751299Ab2GUPhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 11:37:52 -0400
In-Reply-To: <alpine.WNT.2.00.1207201807470.14524@jbrandeb-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 18:17 -0700, Brandeburg, Jesse wrote:
> 
> On Fri, 20 Jul 2012, Ben Hutchings wrote:
> > Why don't you set ecmd->eth_tp_mdix_ctrl here?
> > 
> > If you also leave it as 0, it's impossible for userland to tell whether
> > the current mode was forced or automatically selected.
> 
> Thanks for the review, right now the get interface (and ethtool display) 
> doesn't support any way to report if the setting was forced or not.  I 
> didn't think about changing the get because I didn't want to modify the 
> userland reporting (I also figured it was a simple interface right now, 
> and didn't need changing, and was focused on the _set_ which is the part 
> fixing the users' reported bugs.)

Everything else you can change with ETHTOOL_SSET is also reported by
ETHTOOL_GSET; why would this be any different?

> I think the patches as they currently stand are okay, do you agree? I 
> would be glad to submit a followon to implement the new "get" interface if 
> we can hash out the interface changes, but I see no reason to gate these 
> patches.

You left this for 20 months, what's the hurry now?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
