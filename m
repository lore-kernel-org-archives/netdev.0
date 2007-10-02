From: David Miller <davem@davemloft.net>
Subject: Re: How do queue-less virtual devices wake higher level senders?
Date: Mon, 01 Oct 2007 17:04:10 -0700 (PDT)
Message-ID: <20071001.170410.40806513.davem@davemloft.net>
References: <47018772.4060803@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751770AbXJBAEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 20:04:11 -0400
In-Reply-To: <47018772.4060803@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 01 Oct 2007 16:49:06 -0700

> For 'real' hardware, it seems that the netif_stop_queue and
> netif_wake_queue methods handle stopping and waking the
> higher level senders, but for virtual devices with no
> queues, how does this work?

They don't queue, there is nothing to stop or wakeup.
