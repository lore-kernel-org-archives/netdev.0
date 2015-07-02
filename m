From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Thu, 2 Jul 2015 17:06:30 -0600
Message-ID: <20150702230630.GA26691@obsidianresearch.com>
References: <20150630225255.GA22529@obsidianresearch.com>
 <5593B48F.2060403@iogearbox.net>
 <5594F7AE.3010704@iogearbox.net>
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
Received: from quartz.orcorp.ca ([184.70.90.242]:58658 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986AbbGBXGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2015 19:06:41 -0400
Content-Disposition: inline
In-Reply-To: <5594F7AE.3010704@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2015 at 10:34:54AM +0200, Daniel Borkmann wrote:
> >So, commit c02db8c6290b moved it into a nested attribute (IFLA_VF_INFO)
> >where we indeed don't do further validation. Imho, we should pass the
> >parsed attribute table from nla_parse_nested() down into do_setvfinfo(),
> >something like the below; I can give it a test run on my ixgbe.
> 
> Sorry for the late reply, something like this looks good from my side.

Okay, since it is your patch, will you send it to DaveM with my
Reported-By?

Cheers,
Jason
