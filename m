From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TPROXY] supply a struct flowi->flags argument in
 inet_sk_rebuild_header()
Date: Thu, 20 Nov 2008 01:08:14 -0800 (PST)
Message-ID: <20081120.010814.73015558.davem@davemloft.net>
References: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
	<c23fce5cd1bf67e9123ac6e5a776825b8664a124.1227023129.git.bazsi@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35383
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbYKTJIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:08:14 -0500
In-Reply-To: <c23fce5cd1bf67e9123ac6e5a776825b8664a124.1227023129.git.bazsi@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Tue, 18 Nov 2008 16:33:35 +0100

>     inet_sk_rebuild_header() does a new route lookup if the dst_entry
>     associated with a socket becomes stale. However inet_sk_rebuild_header()
>     didn't use struct flowi->flags, causing the route lookup to
>     fail for foreign-bound IP_TRANSPARENT sockets, causing an error
>     state to be set for the sockets in question.
> 
> Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>

Applied to net-2.6, thanks.
