From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: 2.6.20 and multipath routing
Date: Thu, 10 May 2007 18:42:00 -0400
Message-ID: <46439FB8.8000502@redhat.com>
References: <003d01c79349$60da1870$228e4950$@biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giampaolo Tomassoni <Giampaolo@Tomassoni.biz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756904AbXEJWmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 18:42:05 -0400
In-Reply-To: <003d01c79349$60da1870$228e4950$@biz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Giampaolo Tomassoni wrote:
> 
> 		default  src 1.2.1.6
> 		        nexthop via 1.2.2.254  dev atm0 weight 1
> 		        nexthop via 1.1.2.254  dev atm1 weight 1
> 

When I tried this I found that weight 1 didn't work -- all traffic
went out one interface until I changed both weights to 50.

And on ethernet, I had to have static ARP entries or the kernel
would ARP on one interface, and if it didn't get a reply in less
than one microsecond it would immediately go to the second
interface.
