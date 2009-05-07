From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Thu, 07 May 2009 14:55:42 -0700 (PDT)
Message-ID: <20090507.145542.23552646.davem@davemloft.net>
References: <4A031596.4020904@cosmosbay.com>
	<4A031867.9060806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34442
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753107AbZEGVzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:55:46 -0400
In-Reply-To: <4A031867.9060806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 07 May 2009 19:20:39 +0200

> We can avoid waking up tasks not interested in receive notifications,
> using wake_up_interruptible_poll() instead of wake_up_interruptible()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Nice work Eric, applied!
