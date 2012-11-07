From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] packet: tx_ring: allow the user to choose
 tx data offset
Date: Wed, 07 Nov 2012 18:55:13 -0500 (EST)
Message-ID: <20121107.185513.577120386806348661.davem@davemloft.net>
References: <1352279447-2980-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul.Chavent@onera.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab2KGXzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 18:55:14 -0500
In-Reply-To: <1352279447-2980-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Chavent <Paul.Chavent@onera.fr>
Date: Wed,  7 Nov 2012 10:10:47 +0100

> The tx data offset of packet mmap tx ring used to be :
> (TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))
> 
> The problem is that, with SOCK_RAW socket, the payload (14 bytes after
> the beginning of the user data) is misaligned.
> 
> This patch allows to let the user gives an offset for it's tx data if
> he desires.
> 
> Set sock option PACKET_TX_HAS_OFF to 1, then specify in each frame of
> your tx ring tp_net for SOCK_DGRAM, or tp_mac for SOCK_RAW.
> 
> Signed-off-by: Paul Chavent <paul.chavent@onera.fr>

Applied, thanks.
