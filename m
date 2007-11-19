From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Mon, 19 Nov 2007 16:29:33 +0100
Message-ID: <20071119152933.GA19126@one.firstfloor.org>
References: <p73bq9tau2x.fsf@bingen.suse.de> <20071117.160926.232024605.davem@davemloft.net> <20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35982 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbXKSP3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 10:29:36 -0500
Content-Disposition: inline
In-Reply-To: <20071118.144010.236028466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > 
> > > All of our options suck, we just have to choose the least sucking one
> > > and right now to me that's decrementing the counter as much as I
> > > empathize with the SNMP application overflow detection issue.
> > 
> > If the SNMP monitor detects an false overflow the error it reports 
> > will be much worse than a single missing packet. So you would replace 
> > one error with a worse error.
> 
> This can be fixed, the above cannot.

I don't see how, short of breaking the interface
(e.g. reporting 64bit or separate overflow counts)
-Andi
