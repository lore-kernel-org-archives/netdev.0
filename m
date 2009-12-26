From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] gianfar: update txq->trans_start rather than
 dev->trans_start
Date: Fri, 25 Dec 2009 18:45:03 -0800 (PST)
Message-ID: <20091225.184503.28832017.davem@davemloft.net>
References: <1260972281-20012-1-git-send-email-Sandeep.Kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com
To: Sandeep.Kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53521
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756277AbZLZCpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:45:02 -0500
In-Reply-To: <1260972281-20012-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Date: Wed, 16 Dec 2009 19:34:41 +0530

> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
> ---
> 
>  *. Please let me know if updating txq->trans_start in gfar_start is
>     alright, although updating txq->trans_start in gfar_start_xmit( )
>     should be done.

See commit 08baf561083bc27a953aa087dd8a664bb2b88e8e, you don't have to
update *->trans_start at all, the generic code will do it for you.

For example, this is why you won't be able to find any trans_start
references in drivers such as ixgbe
