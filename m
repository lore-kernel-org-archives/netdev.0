From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: invert error code in netlink_set_err()
Date: Tue, 03 Mar 2009 23:37:40 -0800 (PST)
Message-ID: <20090303.233740.206627831.davem@davemloft.net>
References: <20090303233535.7346.25867.stgit@Decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbZCDHhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:37:55 -0500
In-Reply-To: <20090303233535.7346.25867.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 04 Mar 2009 00:35:35 +0100

> The callers of netlink_set_err() currently pass a negative value
> as parameter for the error code. However, sk->sk_err wants a
> positive error value. Without this patch, skb_recv_datagram() called
> by netlink_recvmsg() may return a positive value to report an error.
> 
> Another choice to fix this is to change callers to pass a positive
> error value, but this seems a bit inconsistent and error prone
> to me. Indeed, the callers of netlink_set_err() assumed that the
> (usual) negative value for error codes was fine before this patch :).
> 
> This patch also includes some documentation in docbook format
> for netlink_set_err() to avoid this sort of confusion.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks a lot Pablo.
