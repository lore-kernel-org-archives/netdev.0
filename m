From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: immediate send IPI in
 process_backlog()
Date: Thu, 22 Apr 2010 00:22:00 -0700 (PDT)
Message-ID: <20100422.002200.24658929.davem@davemloft.net>
References: <1271883898.7895.3379.camel@edumazet-laptop>
	<20100422.002118.107274505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0DVHVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:21:55 -0400
In-Reply-To: <20100422.002118.107274505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 22 Apr 2010 00:21:18 -0700 (PDT)

> Eric, irqs are enabled in process_backlog(), so I don't know how legal
> it is to invoke net_rps_action_and_irq_enable() from there.

Nevermind I mis-read your patch.

Ignore me, I'll apply this.

Thanks!
