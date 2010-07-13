From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] xtsonic: free irq if sonic_open() fails
Date: Mon, 12 Jul 2010 20:33:51 -0700 (PDT)
Message-ID: <20100712.203351.63038681.davem@davemloft.net>
References: <1278759704-7777-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, u.kleine-koenig@pengutronix.de,
	tj@kernel.org, joe@perches.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41438
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752630Ab0GMDdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:33:36 -0400
In-Reply-To: <1278759704-7777-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 10 Jul 2010 15:01:44 +0400

> xtsonic_open() doesn't check sonic_open() return code. If it is error
> we must free requested IRQ.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
