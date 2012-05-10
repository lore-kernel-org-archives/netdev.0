From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: fix losing of NEQ events when one event occurred
 early
Date: Wed, 09 May 2012 20:29:13 -0400 (EDT)
Message-ID: <20120509.202913.886545227635873372.davem@davemloft.net>
References: <1336608618-31497-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab2EJA3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:29:21 -0400
In-Reply-To: <1336608618-31497-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Wed,  9 May 2012 21:10:18 -0300

> +	/* Handle any events that might be pending. */
> +	tasklet_hi_schedule(&adapter->neq_tasklet);
> +
>  
>  	ret = 0;

These extra empty lines are completely unnecessary, please remove
them.
