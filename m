From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] tipc: add a bounds check in
 link_recv_changeover_msg()
Date: Mon, 06 May 2013 16:17:26 -0400 (EDT)
Message-ID: <20130506.161726.1012915897561757486.davem@davemloft.net>
References: <20130506182840.GA21347@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756334Ab3EFUR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 16:17:27 -0400
In-Reply-To: <20130506182840.GA21347@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 6 May 2013 21:28:41 +0300

> The bearer_id here comes from skb->data and it can be a number from 0 to
> 7.  The problem is that the ->links[] array has only 2 elements so I
> have added a range check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
