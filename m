From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 2/3] net: expose ebridge FDB with priv flag
 IFF_OFFLOADED_FDB
Date: Fri, 2 Mar 2012 20:00:42 +0000
Message-ID: <1330718442.2611.37.camel@bwh-desktop>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
	 <20120229071719.10937.68718.stgit@jf-dev1-dcblab>
	 <1330718193.2611.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jhs@mojatatu.com>, <shemminger@vyatta.com>,
	<kernel@wantstofly.org>, <hadi@cyberus.ca>, <roprabhu@cisco.com>,
	<mst@redhat.com>, <netdev@vger.kernel.org>,
	<gregory.v.rose@intel.com>, <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6322 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756152Ab2CBUAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 15:00:46 -0500
In-Reply-To: <1330718193.2611.36.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-02 at 19:56 +0000, Ben Hutchings wrote:
[...]
> General comment: why should the software bridge code be loaded in order
> to control a hardware bridge?  (It's not even the only software bridge
> we have!)  It would perhaps be neater to have separate modules for the
> software bridge, the rtnetlink bridge ops, and the glue functions for
> hardware bridges.  But that could be done later.

I see from the other thread that you're already well aware for this.
So, no need to answer it.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
