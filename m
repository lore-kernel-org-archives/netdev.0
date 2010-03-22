From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] GTSM for IPv6
Date: Sun, 21 Mar 2010 20:16:08 -0700 (PDT)
Message-ID: <20100321.201608.124071215.davem@davemloft.net>
References: <20100319095640.42c8d82d@nehalam>
	<alpine.LRH.2.00.1003191959050.31512@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753726Ab0CVDPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:15:46 -0400
In-Reply-To: <alpine.LRH.2.00.1003191959050.31512@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Fri, 19 Mar 2010 20:02:48 +0200 (EET)

> On Fri, 19 Mar 2010, Stephen Hemminger wrote:
>> Also RFC doesn't explicitly address GTSM on IPV6.
>> Maybe the RFC editors think the problem will magically no longer exist
>> in IPv6 world because everyone will be using IPsec.
> 
> Hmm. When I was editing the RFC, I seem to have put in some text about
> IPv6 (i.e. difference in TTL vs Hop Count naming).  As far as I know,
> there is no other difference :-)
> 
> In IPV6_MIN_HOPS hops would seem to point toward the "number of hops"
> which is logically the opposite: 255-$value.  So maybe
> IPV6_MIN_HOPCOUNT is better. But I can live with it either way :-)

Stephen, make whatever decision your deem appropriate about
the name and resubmit this for net-next-2.6, thanks!
