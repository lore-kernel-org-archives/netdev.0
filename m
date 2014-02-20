From: Aaron Brown <aaron.f.brown@intel.com>
Subject: Re: [net-next 05/14 v2] i40evf: fix up strings in init task
Date: Wed, 19 Feb 2014 21:16:12 -0800
Message-ID: <1392873372.2629.13.camel@localhost>
References: <1392868178-7011-1-git-send-email-aaron.f.brown@intel.com>
	 <1392868178-7011-2-git-send-email-aaron.f.brown@intel.com>
	 <1392869350.24844.22.camel@joe-AO722> <1392871887.2629.10.camel@localhost>
	 <1392872294.24844.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15009 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbaBTFQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 00:16:15 -0500
In-Reply-To: <1392872294.24844.25.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 20:58 -0800, Joe Perches wrote:
> On Wed, 2014-02-19 at 20:51 -0800, Aaron Brown wrote:
> > On Wed, 2014-02-19 at 20:09 -0800, Joe Perches wrote:
> > > On Wed, 2014-02-19 at 19:49 -0800, Aaron Brown wrote:
> > > > Make sure errors are reported at the correct log level, quit printing
> > > > the function name every time, and make the messages more consistent in
> > > > format.
> > > []
> > > > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> []
> > > +		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using random\n",
> > > > +			 adapter->hw.mac.addr);
> > > The "AC" after %pM is superfluous.
> > Thanks Joe, guess I'll be making another spin...
> 
> Or send another patch after this one because there
> are 2 %pMAC uses in i40evf_main.c

That works.  I'll bug Mitch to look for them when he does a hunt for other OOM messages that he said he'd do and send them up later.  So I guess this patch can stand for now.
