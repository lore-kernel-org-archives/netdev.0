From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: rx_dropped count for USB ethernet interfaces
Date: Fri, 27 Sep 2013 09:39:00 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7362@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com><20130925.144640.1661224048195310923.davem@davemloft.net><AE90C24D6B3A694183C094C60CF0A2F6026B735E@saturn3.aculab.com> <20130926.132125.1343558938307288175.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60050 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752283Ab3I0ImC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:42:02 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26948-03 for <netdev@vger.kernel.org>;
 Fri, 27 Sep 2013 09:42:00 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130926.132125.1343558938307288175.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Thu, 26 Sep 2013 10:32:24 +0100
> 
> > It isn't exactly useful behaviour though.
> 
> In your opinion.
> 
> We have tracepoints for people who want more fine grained drops
> in these kinds of situations.
> 
> Also, the behavior of this statistic has existed for more than a
> decade so changing it is really not in the cards.  Therefore any
> discussion about what would have been the best samentic to choose from
> the beginning is moot.

I suspect that not many people have networks with broadcast packets
for non-IP protocols - so don't ever see rx_dropped being incremented
because there wasn't a protocol stack looking for the packet.

A similar problem will arise if promiscuous mode is enabled
by someone who only wants a specific protocol - eg a specific
ethertype or a single LLC SAP value.

	David
