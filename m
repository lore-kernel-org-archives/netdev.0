From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Thu, 9 Oct 2008 19:23:43 -0700
Message-ID: <OFDFB5153E.E37AC842-ON882574DE.000CEB50-882574DE.000D286A@us.ibm.com>
References: <48EEA752.6030505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:58441 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbYJJCXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 22:23:48 -0400
In-Reply-To: <48EEA752.6030505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't see any way to address David Steven's comment since there is 
> currently no NA tunable in the IPv6 code.

Brian,
        How do you feel about doubling up with dad_transmits for that
part?
        At least the switch/cache updating portion is the same
in both cases.

                                                        +-DLS

