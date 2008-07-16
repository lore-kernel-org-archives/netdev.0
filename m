From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/13]: netdev: Allocate multiple queues for TX.
Date: Wed, 16 Jul 2008 00:37:00 -0700 (PDT)
Message-ID: <20080716.003700.193213605.davem@davemloft.net>
References: <20080710.035610.167480342.davem@davemloft.net>
	<20080716070108.GA4099@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752013AbYGPHhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 03:37:03 -0400
In-Reply-To: <20080716070108.GA4099@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 16 Jul 2008 07:01:08 +0000

> I wonder if it was tested with lockdep? It seems additional
> annotation is needed for such nesting (not counting rx_queue.lock
> annotation).

I know, and I know about your patch wrt the queue lock
initializations.

I hope to solve that and other things as I respin the multiqueue
changes.
