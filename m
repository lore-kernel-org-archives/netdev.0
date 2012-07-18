From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: refine IFF_XMIT_DST_RELEASE
 capability
Date: Wed, 18 Jul 2012 09:32:38 -0700 (PDT)
Message-ID: <20120718.093238.1442501054674720136.davem@davemloft.net>
References: <1342563588.2626.1224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab2GRQcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:32:39 -0400
In-Reply-To: <1342563588.2626.1224.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 00:19:48 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Some workloads greatly benefit of IFF_XMIT_DST_RELEASE capability
> on output net device, avoiding dirtying dst refcount.
> 
> bonding currently disables IFF_XMIT_DST_RELEASE unconditionally.
> 
> If all slaves have the IFF_XMIT_DST_RELEASE bit set, then
> bonding master can also have it in its priv_flags
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
