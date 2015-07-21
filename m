From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix compatibility bug
Date: Tue, 21 Jul 2015 16:24:18 -0700 (PDT)
Message-ID: <20150721.162418.254612120770236450.davem@davemloft.net>
References: <1437475348-2163-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGUXYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 19:24:19 -0400
In-Reply-To: <1437475348-2163-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 21 Jul 2015 06:42:28 -0400

> In commit d999297c3dbbe7fdd832f7fa4ec84301e170b3e6
> ("tipc: reduce locking scope during packet reception") we introduced
> a new function tipc_link_proto_rcv(). This function contains a bug,
> so that it sometimes by error sends out a non-zero link priority value
> in created protocol messages.
> 
> The bug may lead to an extra link reset at initial link establising
> with older nodes. This will never happen more than once, whereafter
> the link will work as intended.
> 
> We fix this bug in this commit.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
