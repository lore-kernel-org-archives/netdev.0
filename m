From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: fix addr_len/msg->msg_namelen assignment in
 recv_error and rxpmtu functions
Date: Sat, 23 Nov 2013 14:49:00 -0800 (PST)
Message-ID: <20131123.144900.364271861197097555.davem@davemloft.net>
References: <20131122234612.GB15822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, spender@grsecurity.net, mpb.mail@gmail.com,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328Ab3KWWk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:40:28 -0500
In-Reply-To: <20131122234612.GB15822@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 23 Nov 2013 00:46:12 +0100

> Commit bceaa90240b6019ed73b49965eac7d167610be69 ("inet: prevent leakage
> of uninitialized memory to user in recv syscalls") conditionally updated
> addr_len if the msg_name is written to. The recv_error and rxpmtu
> functions relied on the recvmsg functions to set up addr_len before.
> 
> As this does not happen any more we have to pass addr_len to those
> functions as well and set it to the size of the corresponding sockaddr
> length.
> 
> This broke traceroute and such.
> 
> Fixes: bceaa90240b6 ("inet: prevent leakage of uninitialized memory to user in recv syscalls")
> Reported-by: Brad Spengler <spender@grsecurity.net>
> Reported-by: Tom Labanowski
> Cc: mpb <mpb.mail@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
