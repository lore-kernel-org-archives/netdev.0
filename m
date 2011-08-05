From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/1] netxen: add vlan accel support
Date: Fri, 05 Aug 2011 02:42:47 -0700 (PDT)
Message-ID: <20110805.024247.1468547132343070339.davem@davemloft.net>
References: <1312536015-21719-1-git-send-email-amit.salecha@qlogic.com>
	<1312536015-21719-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1HEJmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 05:42:55 -0400
In-Reply-To: <1312536015-21719-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <amit.salecha@qlogic.com>
Date: Fri, 5 Aug 2011 02:20:15 -0700

> From: Rajesh K Borundia <rajesh.borundia@qlogic.com>
> 
> o This increases performance on vlan interface.
> o In case of fw reset, need to reprogram the ip addresses.
> o Support LRO on vlan interface.
> 
> Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

As far as I can tell your card doesn't accelerate VLANs in hardware
at all, is this true?

I think it's very cumbersome and it doesn't make sense for every
driver in your situation to add this same sequence of software calls.

Some generic facility and interfaces should be created so that the
code doing this software VLAN acceleration is consolidated into
one place and any driver can follow a simple to use API in order
to make use of it.
