From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 14:08:12 -0400
Message-ID: <48ECF70C.8080108@hp.com>
References: <OF2E92DF11.37B32D55-ON882574DC.0060DD39-882574DC.006110E1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:4617 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbYJHSIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:08:16 -0400
In-Reply-To: <OF2E92DF11.37B32D55-ON882574DC.0060DD39-882574DC.006110E1@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Brian,
>         I'll make the same comment I did in the earlier version,
> which is I don't think we need a new control for the count. Instead,
> it should use the count for unsolicited NA's we send when adding
> an address. It is the same case, really, and I, FWIW, would rather
> we didn't have any more sysctl's than we need.
> 
>                                                 +-DLS
> 

Are you referring to 'dad_transmits' because I don't see any sysctls
that control the number of unsolicited NAs.  In fact, in normal operations
we don't send any unsolicited NAs at all.

This functionality effectively duplicates the gratuitous arps controls on the
bond.

-vlad

