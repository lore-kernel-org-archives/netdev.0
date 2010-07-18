From: David Miller <davem@davemloft.net>
Subject: Re: [patch] arcnet: fix signed bug in probe function
Date: Sun, 18 Jul 2010 15:07:40 -0700 (PDT)
Message-ID: <20100718.150740.26966207.davem@davemloft.net>
References: <20100717172127.GI17585@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50847
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757435Ab0GRWHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 18:07:24 -0400
In-Reply-To: <20100717172127.GI17585@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 17 Jul 2010 19:21:28 +0200

> probe_irq_off() returns the first irq found or if two irqs are found
> then it returns the negative of the first irq found.  We can cast
> dev->irq to an int so that the test for negative values works.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
