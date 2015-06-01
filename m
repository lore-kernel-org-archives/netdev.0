From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Mon, 01 Jun 2015 16:51:32 -0700 (PDT)
Message-ID: <20150601.165132.685895742264313831.davem@davemloft.net>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbbFAXvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 19:51:33 -0400
In-Reply-To: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Mon,  1 Jun 2015 21:55:06 +0900

> Currently packets with non-hardware-accelerated vlan cannot be handled
> by GRO. This causes low performance for 802.1ad and stacked vlan, as their
> vlan tags are currently not stripped by hardware.
> 
> This patch adds GRO support for non-hardware-accelerated vlan and
> improves receive performance of them.
> 
> Test Environment:
>  vlan device (.1Q) on vlan device (.1ad) on ixgbe (82599)
> 
> Result:
 ...
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

So I applied this, but gave the new offloads a priority of 10.

Thanks.
