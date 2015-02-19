From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: failed trigger should not cause
 BUG_ON()
Date: Thu, 19 Feb 2015 13:24:43 -0500
Message-ID: <20150219182443.GA15948@oracle.com>
References: <54E62855.5080201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34373 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903AbbBSSYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 13:24:50 -0500
Content-Disposition: inline
In-Reply-To: <54E62855.5080201@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/19/15 13:15), David L Stevens wrote:
> An error return from __vnet_tx_trigger() sets the TX descriptor to
> VIO_DESC_FREE while leaving port->tx_bufs[txi].skb set. This leads
> to a BUG_ON() the next time this descriptor is used.
> 
> This patch frees the pending skb when getting a trigger error to
> match the VIO_DESC_FREE state.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
