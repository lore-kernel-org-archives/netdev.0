From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] tipc: separate link and link
 aggregation layer
Date: Mon, 20 Jul 2015 20:41:31 -0700 (PDT)
Message-ID: <20150720.204131.1684390421785185339.davem@davemloft.net>
References: <1437080071-6686-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbGUDlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:41:32 -0400
In-Reply-To: <1437080071-6686-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 16 Jul 2015 16:54:18 -0400

> This is the first batch of a longer series that has two main objectives:
> 
> o Finer lock granularity during message sending and reception,
>   especially regarding usage of the node spinlock.
> 
> o Better separation between the link layer implementation and the link
>   aggregation layer, represented by node.c::struct tipc_node.
> 
> Hopefully these changes also make this part of code somewhat easier
> to comprehend and maintain.

Series applied, thanks Jon.
