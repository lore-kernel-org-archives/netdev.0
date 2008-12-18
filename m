From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 v3 1/5] gianfar: Fix packet drop when out of
 memory
Date: Wed, 17 Dec 2008 16:52:40 -0800 (PST)
Message-ID: <20081217.165240.175376796.davem@davemloft.net>
References: <1229550175-15600-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbYLRAwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:52:38 -0500
In-Reply-To: <1229550175-15600-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 17 Dec 2008 15:42:51 -0600

> The patch which fixed gianfar so it drops packets when it runs out
> of memory left in the code which frees the skb when it drops packets.
> Change the code so that we only free the skb if the new skb was successfully
> created.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.
