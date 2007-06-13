From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/15] spidernet: null out skb pointer after its been used.
Date: Wed, 13 Jun 2007 16:10:17 -0400
Message-ID: <46704F29.8060805@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39240 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbXFMUKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:10:22 -0400
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Avoid kernel crash in mm/slab.c due to double-free of pointer.
> 
> If the ethernet interface is brought down while there is still
> RX traffic in flight, the device shutdown routine can end up
> trying to double-free an skb, leading to a crash in mm/slab.c
> Avoid the double-free by nulling out the skb pointer.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> 
> ----
>  drivers/net/spider_net.c |    1 +
>  1 file changed, 1 insertion(+)

applied 1-5, 7 to #upstream-fixes (2.6.22)

patch #6 was ignored, because it was already upstream


