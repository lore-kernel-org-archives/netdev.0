From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Sun, 27 Mar 2011 17:59:36 -0700 (PDT)
Message-ID: <20110327.175936.189721420.davem@davemloft.net>
References: <1300603423.1869.18.camel@dan>
	<1300639685.26693.286.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drosenberg@vsecurity.com, ralf@linux-mips.org,
	netdev@vger.kernel.org, security@kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752340Ab1C1BAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:00:15 -0400
In-Reply-To: <1300639685.26693.286.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 20 Mar 2011 16:48:05 +0000

> Subject: [PATCH] rose: Add length checks to CALL_REQUEST parsing
> 
> Define some constant offsets for CALL_REQUEST based on the description
> at <http://www.techfest.com/networking/wan/x25plp.htm> and the
> definition of ROSE as using 10-digit (5-byte) addresses.  Use them
> consistently.  Validate all implicit and explicit facilities lengths.
> Validate the address length byte rather than either trusting or
> assuming its value.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
