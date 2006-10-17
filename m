From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling for
	ATM/ADSL (kernel)
Date: Tue, 17 Oct 2006 09:07:24 -0400
Message-ID: <1161090444.5555.13.camel@jzny2>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:30114 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750872AbWJQNH1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 09:07:27 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GZofJ-0006R3-40
	for netdev@vger.kernel.org; Tue, 17 Oct 2006 09:07:29 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-17-10 at 09:34 +1000, Russell Stuart wrote:
> The Linux traffic's control engine inaccurately calculates
> transmission times for packets sent over ADSL links.  For
> some packet sizes the error rises to over 50%.  This occurs
> because ADSL uses ATM as its link layer transport, and ATM
> transmits packets in fixed sized 53 byte cells.
> 
> This changes the kernel rate table lookup, to be able to lookup
> packet transmission times over all ATM links, including ADSL,
> with perfect accuracy. The accuracy is dependent on the rate
> table that is calculated in userspace by iproute2 command tc.
> 
> A longer presentation of the patch, its rational, what it
> does and how to use it can be found here:
>    http://www.stuart.id.au/russell/files/tc/tc-atm/
> 
> A earlier version of the patch, and a _detailed_ empirical
> investigation of its effects can be found here:
>    http://www.adsl-optimizer.dk/
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> Signed-off-by: Russell Stuart <russell-tcatm@stuart.id.au>

ACKed-by: Jamal Hadi Salim

When Patrick has his patch ready after this goes in we can revisit.

cheers,
jamal

