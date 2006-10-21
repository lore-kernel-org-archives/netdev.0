From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Fri, 20 Oct 2006 19:20:50 -0700 (PDT)
Message-ID: <20061020.192050.98553432.davem@davemloft.net>
References: <17720.12801.843076.819750@localhost.localdomain>
	<20061019.195921.31639913.davem@davemloft.net>
	<17721.33606.219025.313449@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pjf@asn.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27540
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030377AbWJUCUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 22:20:49 -0400
To: stephen@dino.dnsalias.com
In-Reply-To: <17721.33606.219025.313449@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Date: Fri, 20 Oct 2006 19:17:42 -0700

> path-MTU gets interesting[1] in the context of an an IPsec gateway
> (i.e. tunnel mode IPsec) and there is definitely variability as to how
> reliably an ICMP will be returned in the case that the MTU is exceeded
> somewhere between the two endpoints.  Throw in port/protocol based
> selectors[2] or IPv4(IPv6) traffic encrypted with an IPv6(IPv4)
> header[3] and the chances of success go down.

Yes, this has been discussed to death here previosly.

It can be made more reliable, the fact that most of the
implementations suck (to some extent including Linux's) should not
deter us trying to make it work as reliably as possible.

I just think that this ethernet level crypto talk is a complete waste
of time, there are much better things to concentrate on in my opinion.
:-)
