From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] xen-netfront: always keep the Rx ring full of
 requests
Date: Fri, 03 Oct 2014 15:54:12 -0700 (PDT)
Message-ID: <20141003.155412.519359151723073387.davem@davemloft.net>
References: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbaJCWwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:52:11 -0400
In-Reply-To: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 2 Oct 2014 14:33:46 +0100

> A full Rx ring only requires 1 MiB of memory.  This is not enough
> memory that it is useful to dynamically scale the number of Rx
> requests in the ring based on traffic rates.
> 
> Keeping the ring full of Rx requests handles bursty traffic better
> than trying to converges on an optimal number of requests to keep
> filled.
> 
> On a 4 core host, an iperf -P 64 -t 60 run from dom0 to a 4 VCPU guest
> improved from 5.1 Gbit/s to 5.6 Gbit/s.  Gains with more bursty
> traffic are expected to be higher.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Can I get an ACK from someone else knowledgable about this area?

Thanks!
