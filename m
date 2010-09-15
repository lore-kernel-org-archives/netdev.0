From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bug 18212] New: force_igmp_version ignored when a IGMPv3 query
 received (+1 line patch)
Date: Wed, 15 Sep 2010 02:05:54 -0700
Message-ID: <OF04086579.D69F0B29-ON8825779F.0031ADF6-8825779F.0031FBA8@us.ibm.com>
References: <20100910091936.75eabbf6@nehalam>	<OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com> <20100914.142418.149835514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:52856 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703Ab0IOJF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 05:05:58 -0400
In-Reply-To: <20100914.142418.149835514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 09/14/2010 02:24:18 PM:

> 
> Do you have an alternative patch to suggest?

        No, I think it's not broken. I think the broken part is
a switch sending v3 queries when a v2 querier is present.

                                                        +-DLS

