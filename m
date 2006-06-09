From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: Re: [patch 06/17] neighbour.c, pneigh_get_next() skips published entry
Date: Fri, 9 Jun 2006 16:14:13 -0400
Message-ID: <413FEEF1743111439393FB76D0221E4804A56AF5@leopard.zoo.q9networks.com>
Cc: <davem@davemloft.net>, <akpm@osdl.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.q9.com ([216.220.35.253]:12986 "EHLO mx2.q9.com")
	by vger.kernel.org with ESMTP id S1030484AbWFIUOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 16:14:09 -0400
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 9 Jun 2006, Herbert Xu wrote:

> Could you post an exact sequence of commands that reproduces the bug?
> That would help us in verifying your fix.
> 

Publish a large number of ARP entries (greater than 10 required on my
system):
'arp -Ds <IP> <iface> pub'

View output of /proc/net/arp:

'dd if=/proc/net/arp of=arp-1024.out bs=1024'

The produced output will be missing on average one entry for every ten
entries published. Occasionally, the output will vary and the missing
entry will be displayed.


