From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net-next 4/6] e1000: configure and read MDI settings
Date: Fri, 20 Jul 2012 18:17:21 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1207201807470.14524@jbrandeb-mobl2.amr.corp.intel.com>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1342820631-19738-5-git-send-email-jeffrey.t.kirsher@intel.com> <1342826859.11373.123.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Tushar Dave <tushar.n.dave@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13163 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522Ab2GUBRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 21:17:24 -0400
In-Reply-To: <1342826859.11373.123.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 20 Jul 2012, Ben Hutchings wrote:
> Why don't you set ecmd->eth_tp_mdix_ctrl here?
> 
> If you also leave it as 0, it's impossible for userland to tell whether
> the current mode was forced or automatically selected.

Thanks for the review, right now the get interface (and ethtool display) 
doesn't support any way to report if the setting was forced or not.  I 
didn't think about changing the get because I didn't want to modify the 
userland reporting (I also figured it was a simple interface right now, 
and didn't need changing, and was focused on the _set_ which is the part 
fixing the users' reported bugs.)

I think the patches as they currently stand are okay, do you agree? I 
would be glad to submit a followon to implement the new "get" interface if 
we can hash out the interface changes, but I see no reason to gate these 
patches.
