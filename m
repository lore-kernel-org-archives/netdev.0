From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1.1] af_packet: don't emit packet on orig fanout group
Date: Mon, 20 Aug 2012 02:37:43 -0700 (PDT)
Message-ID: <20120820.023743.1739374734021977895.davem@davemloft.net>
References: <20120816.145253.939105041613744695.davem@davemloft.net>
	<1345190578-28722-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab2HTJho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:37:44 -0400
In-Reply-To: <1345190578-28722-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>
Date: Fri, 17 Aug 2012 10:02:58 +0200

> If a packet is emitted on one socket in one group of fanout sockets,
> it is transmitted again. It is thus read again on one of the sockets
> of the fanout group. This result in a loop for software which
> generate packets when receiving one.
> This retransmission is not the intended behavior: a fanout group
> must behave like a single socket. The packet should not be
> transmitted on a socket if it originates from a socket belonging
> to the same fanout group.
> 
> This patch fixes the issue by changing the transmission check to
> take fanout group info account.
> 
> Reported-by: Aleksandr Kotov <a1k@mail.ru>
> Signed-off-by: Eric Leblond <eric@regit.org>

Applied, thanks a lot Eric.
