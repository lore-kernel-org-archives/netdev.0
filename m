From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 14:11:43 -0700 (PDT)
Message-ID: <20070411.141143.82097512.davem@davemloft.net>
References: <461D447C.4070408@candelatech.com>
	<20070411.134804.50594117.davem@davemloft.net>
	<461D4DD7.7020207@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43614
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753240AbXDKVLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 17:11:42 -0400
In-Reply-To: <461D4DD7.7020207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 11 Apr 2007 14:06:31 -0700

> Does the CWND == 1 count as solid?  Any idea how/why this would go
> to 1 in conjunction with the dup acks?
> 
> For the dup acks, I see nothing *but* dup acks on the wire...going in
> both directions interestingly, at greater than 100,000 packets per second.
> 
> I don't mind adding printks...and I've started reading through the code,
> but there is a lot of it, and indiscriminate printks will likely just
> hide the problem because it will slow down performance so much.

If you know that it doesn't take Einstein to figure out that maybe you
should add logging when CWND is one and we're sending out an ACK?

This is why I think you're very lazy Ben and I get very agitated with
all of your reports, you put zero effort into thinking about how to
debug the problem even though you know full well how to do it.
