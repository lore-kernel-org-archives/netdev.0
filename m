From: David Miller <davem@davemloft.net>
Subject: Re: What is RDMA
Date: Mon, 24 Jul 2006 15:39:17 -0700 (PDT)
Message-ID: <20060724.153917.15588754.davem@davemloft.net>
References: <20060707081131.GA2991@gondor.apana.org.au>
	<20060724.152925.85821176.davem@davemloft.net>
	<44C54AF6.3030609@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tom@opengridcomputing.com,
	rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53913
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932303AbWGXWjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:39:08 -0400
To: rick.jones2@hp.com
In-Reply-To: <44C54AF6.3030609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 24 Jul 2006 15:34:30 -0700

> That TOE/iWARP could end-up being precluded by NAT seems so ironic
> from a POE2E standpoint.

To be honest we do not have a pure end to end internet, and some of
our failed experiments in the past prove this :-)

For example, we have an optimization that allows much earlier
termination of TIME_WAIT connections.  It relies upon TCP timestamps
and attributes we can determine about end hosts using that information
(it is yet another Van Jacobson idea btw).  But NAT means that IP+Port
does not necessarily equate to the same host over time, not even over
short periods of time.  A NAT box could be using Port X for host A and
then host B some short time later.

Therefore we had to disable the early timewait recycling trick by
default.
