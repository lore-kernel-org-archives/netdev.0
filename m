From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Fix a_rwnd/rwnd management to reflect real
 state of the receiver's buffer
Date: Tue, 21 Jan 2014 14:36:20 -0800 (PST)
Message-ID: <20140121.143620.1777441472756091252.davem@davemloft.net>
References: <52D8D544.5050501@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, alexander.sverdlin@nsn.com,
	netdev@vger.kernel.org
To: matija.glavinic-pecotic.ext@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaAUWgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:36:21 -0500
In-Reply-To: <52D8D544.5050501@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Date: Fri, 17 Jan 2014 08:01:24 +0100

> Implementation of (a)rwnd calculation might lead to severe performance issues
> and associations completely stalling. These problems are described and solution
> is proposed which improves lksctp's robustness in congestion state.

It would be fantastic if an SCTP expert would review this patch, it's
been rotting in patchwork for 4 days.

Thanks.
