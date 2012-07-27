From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: RE: [PATCH 2/3] pch_gbe: add extra clean tx
Date: Fri, 27 Jul 2012 06:21:11 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011F7C2E@ka-exchange-1.kontronamerica.local>
References: <20120726160011.GC10287@telcoserv5> <20120726.143136.495599687146212368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <andycress@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:47786 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab2G0NVN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 09:21:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20120726.143136.495599687146212368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for applying this Dave.  Sorry I missed the whitespace.  

Andy 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of David Miller
Subject: Re: [PATCH 2/3] pch_gbe: add extra clean tx

> Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

Applied.

 ....
> +		if (unused < 8) {  /* tx queue nearly full */
> +			pr_debug("clean_tx: transmit queue warning
(%x,%x) unused=%d\n",
> +
tx_ring->next_to_clean,tx_ring->next_to_use,unused);
> +		}
> +	   
   ^^^^^^^^^^

Trailing whitespace.

> +		for (j = 0; j < PCH_GBE_TX_WEIGHT; j++) 
                                                       ^^^
Likewise.

Clean this crap up before submitting patches formally, so I don't have
to.
