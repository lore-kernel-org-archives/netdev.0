From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 8 Oct 2008 10:40:13 -0700
Message-ID: <OF2E92DF11.37B32D55-ON882574DC.0060DD39-882574DC.006110E1@us.ibm.com>
References: <48EC091D.7080207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:56803 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbYJHRkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 13:40:42 -0400
In-Reply-To: <48EC091D.7080207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian,
        I'll make the same comment I did in the earlier version,
which is I don't think we need a new control for the count. Instead,
it should use the count for unsolicited NA's we send when adding
an address. It is the same case, really, and I, FWIW, would rather
we didn't have any more sysctl's than we need.

                                                +-DLS

