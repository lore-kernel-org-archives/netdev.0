From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 v2] macsonic: free irqs if sonic_open() fails
Date: Mon, 12 Jul 2010 20:33:42 -0700 (PDT)
Message-ID: <20100712.203342.25143931.davem@davemloft.net>
References: <20100710112229.GX19184@bicker>
	<20100710113057.GA6967@albatros>
	<20100710113906.GB6967@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, kernel-janitors@vger.kernel.org,
	fthain@telegraphics.com.au, u.kleine-koenig@pengutronix.de,
	tj@kernel.org, geert@linux-m68k.org, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752438Ab0GMDd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:33:27 -0400
In-Reply-To: <20100710113906.GB6967@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 10 Jul 2010 15:39:06 +0400

> macsonic_open() doesn't check sonic_open() return code. If it is error
> we must free requested IRQs.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
