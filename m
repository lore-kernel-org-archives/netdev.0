From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_htb: htb_requeue fix
Date: Sat, 09 Feb 2008 23:44:08 -0800 (PST)
Message-ID: <20080209.234408.145736894.davem@davemloft.net>
References: <20080208085749.GA5656@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756229AbYBJHnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:43:37 -0500
In-Reply-To: <20080208085749.GA5656@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 8 Feb 2008 08:57:49 +0000

> htb_requeue() enqueues skbs for which htb_classify() returns NULL.
> This is wrong because such skbs could be handled by NET_CLS_ACT code,
> and the decision could be different than earlier in htb_enqueue().
> So htb_requeue() is changed to work and look more like htb_enqueue().
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks.
