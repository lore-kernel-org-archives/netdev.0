From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 1/2] dcbnl: Aggregated CEE GET operation
Date: Tue, 05 Jul 2011 23:43:24 -0700 (PDT)
Message-ID: <20110705.234324.1045556069748009747.davem@davemloft.net>
References: <1309882582.22577.8.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab1GFGn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:43:29 -0400
In-Reply-To: <1309882582.22577.8.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Tue, 5 Jul 2011 19:16:22 +0300

> The following couple of patches add dcbnl an unsolicited notification of
> the the DCB configuration for the CEE flavor of the DCBX protocol. This
> is useful when the user-mode DCB client is not responsible for
> conducting and resolving the DCBX negotiation (either because the DCBX
> stack is embedded in the HW or the negotiation is handled by another
> agent in he host), but still needs to get the negotiated parameters.
> This functionality already exists for the IEEE flavor of the DCBX
> protocol and these patches add it to the older CEE flavor.
> 
> The first patch extends the CEE attribute GET operation to include not
> only the peer information, but also all the pertinent local
> configuration (negotiated parameters). The second patch adds and export
> a CEE specific notification routine.
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>

Applied.
