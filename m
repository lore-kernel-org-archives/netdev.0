From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 1/4] netns: Tag the network flow with the network namespace
 it is in (v2)
Date: Tue, 04 Dec 2007 21:42:49 +0300
Message-ID: <47559FA9.2080109@sw.ru>
References: <20071204095333.GA6029@iris.sw.ru> <20071204062605.508cf812@shemminger-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	devel@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:63449 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750885AbXLDSlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 13:41:51 -0500
In-Reply-To: <20071204062605.508cf812@shemminger-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Can this be made conditional on network namespaces being configured on?
> That way the flow structure won't have to grow taking more space.
> It matters in DoS attacks where flow cache becomes a critical resource.

could you exactly point me out the flow cache your are talking about.
Is this dst entry cache or struct flow_cache described in the
net/core/flow.c

For the latter case, there is completely no difference in the size on my
x86_64 host with SLAB allocator, i.e. there are 30 objects per slab
with/without fl_net (objsize = 128).

Regards,
	Den

