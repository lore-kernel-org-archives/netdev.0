From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Thu, 2 Jul 2015 10:23:00 -0600
Message-ID: <20150702162300.GA4642@obsidianresearch.com>
References: <20150630225255.GA22529@obsidianresearch.com>
 <5593B48F.2060403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:56111 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125AbbGBQXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 12:23:12 -0400
Content-Disposition: inline
In-Reply-To: <5593B48F.2060403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2015 at 11:36:15AM +0200, Daniel Borkmann wrote:
> Hi Jason,
> 
> On 07/01/2015 12:52 AM, Jason Gunthorpe wrote:
> >It turns out the policy was defined but never actually checked,
> >so lets check it.
> >
> >Fixes: ebc08a6f47ee ("rtnetlink: Add VF config code to rtnetlink")
> 
> I would argue that the actual commit would be ...
> 
> Fixes: c02db8c6290b ("rtnetlink: make SR-IOV VF interface symmetric")

Yes, agree

> So, commit c02db8c6290b moved it into a nested attribute (IFLA_VF_INFO)
> where we indeed don't do further validation. Imho, we should pass the
> parsed attribute table from nla_parse_nested() down into do_setvfinfo(),
> something like the below; I can give it a test run on my ixgbe.

Yes, that is saner overall

Jason
