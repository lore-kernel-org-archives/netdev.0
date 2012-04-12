From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v3 1/8] net: add generic PF_BRIDGE:RTM_ FDB
 hooks
Date: Thu, 12 Apr 2012 21:27:22 +0100
Message-ID: <1334262442.2497.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
	 <20120412170650.2717.56467.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <mst@redhat.com>, <davem@davemloft.net>,
	<sri@us.ibm.com>, <hadi@cyberus.ca>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<krkumar2@in.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42038 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754227Ab2DLU10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:27:26 -0400
In-Reply-To: <20120412170650.2717.56467.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 10:06 -0700, John Fastabend wrote:
[...]
> There is a slight complication in the case with both flags set
> when an error occurs. To resolve this the rtnl handler clears
> the NTF_ flag in the netlink ack to indicate which sets completed
> successfully. The add/del handlers will abort as soon as any
> error occurs.
[...]

Yes, this should work nicely.  Presumably these new flags are completely
ignored by the current implementation of PF_BRIDGE, and new userland
will also be able to use the flags in the response to detect the old
implementation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
