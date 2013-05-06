From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2 v2] tipc: potential divide by zero in
 tipc_link_recv_fragment()
Date: Mon, 06 May 2013 16:17:31 -0400 (EDT)
Message-ID: <20130506.161731.979339772027829304.davem@davemloft.net>
References: <5187F8BD.1080900@cogentembedded.com>
	<20130506193117.GA11399@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756375Ab3EFURd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 16:17:33 -0400
In-Reply-To: <20130506193117.GA11399@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 6 May 2013 22:31:17 +0300

> The worry here is that fragm_sz could be zero since it comes from
> skb->data.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
