From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] lwtunnel: make it really work, for IPv4
Date: Thu, 24 Sep 2015 14:32:01 -0700 (PDT)
Message-ID: <20150924.143201.454135729401541076.davem@davemloft.net>
References: <cover.1442936392.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230AbbIXVcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:32:02 -0400
In-Reply-To: <cover.1442936392.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 22 Sep 2015 18:12:10 +0200

> One of the selling points of lwtunnel was the ability to specify the tunnel
> destination using routes. However, this doesn't really work currently, as
> ARP and ndisc replies are not handled correctly. ARP and ndisc replies won't
> have tunnel metadata attached, thus they will be sent out with the default
> parameters or not sent at all, either way never reaching the requester.
> 
> Most of the egress tunnel parameters can be inferred from the ingress
> metada. The only and important exception is UDP ports. This patchset infers
> the egress data from the ingress data and disallow settings of UDP ports in
> tunnel routes. If there's a need for different UDP ports, a new interface
> needs to be created for each port combination. Note that it's still possible
> to specify the UDP ports to use, it just needs to be done while creating the
> vxlan/geneve interface.
> 
> This covers only ARPs. IPv6 ndisc has the same problem but is harder to
> solve, as there's already dst attached to outgoing skbs. Ideas to solve this
> are welcome.

I'm applying this series as-is, as it's a reasonable step forward in
dealing with this issue.

Thanks Jiri.
