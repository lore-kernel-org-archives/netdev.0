From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Sun, 07 Aug 2011 22:14:54 -0700 (PDT)
Message-ID: <20110807.221454.606981247506041100.davem@davemloft.net>
References: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047Ab1HHFO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:14:57 -0400
In-Reply-To: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Fri, 5 Aug 2011 23:23:51 +0400

> When using nanosleep() in an userspace application we get a ratelimit warning:
> 
> 	NOHZ: local_softirq_pending 08
> 
> According to 481a8199142c050b72bff8a1956a49fd0a75bbe0 the problem is caused by
> netif_rx() function. This patch replaces netif_rx() with netif_rx_ni() which
> has to be used from process/softirq context.
> 
> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>

Applied, thanks.
