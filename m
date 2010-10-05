From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net neigh: neigh_delete() and neigh_add()
 changes
Date: Tue, 05 Oct 2010 14:55:02 -0700 (PDT)
Message-ID: <20101005.145502.209962632.davem@davemloft.net>
References: <1286202456.18293.293.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751844Ab0JEVyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 17:54:41 -0400
In-Reply-To: <1286202456.18293.293.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Oct 2010 16:27:36 +0200

> neigh_delete() and neigh_add() dont need to touch device refcount,
> we hold RTNL when calling them, so device cannot disappear under us.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
