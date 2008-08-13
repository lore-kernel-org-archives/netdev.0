From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rxrpc: Use an IS_ERR test rather than a NULL test
Date: Wed, 13 Aug 2008 02:41:00 -0700 (PDT)
Message-ID: <20080813.024100.169404612.davem@davemloft.net>
References: <200808081355.21787.brunel@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: brunel@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752978AbYHMJk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:40:59 -0400
In-Reply-To: <200808081355.21787.brunel@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Brunel <brunel@diku.dk>
Date: Fri, 8 Aug 2008 13:55:21 +0200

> In case of error, the function rxrpc_get_transport returns an ERR
> pointer, but never returns a NULL pointer. So after a call to this
> function, a NULL test should be replaced by an IS_ERR test.
> 
> A simplified version of the semantic patch that makes this change is
> as follows: 
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by:  Julien Brunel <brunel@diku.dk>
> Signed-off-by:  Julia Lawall <julia@diku.dk>

Applied, thank you.
