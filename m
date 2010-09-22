From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tmspci: fix tr%d in printk
Date: Tue, 21 Sep 2010 18:06:20 -0700 (PDT)
Message-ID: <20100921.180620.104067256.davem@davemloft.net>
References: <alpine.SOC.1.00.1009211011150.28446@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755604Ab0IVBGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:06:01 -0400
In-Reply-To: <alpine.SOC.1.00.1009211011150.28446@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Tue, 21 Sep 2010 10:19:03 +0300 (EEST)

> tmspci driver uses dev->name before register_netdev() and so prints tr%d 
> in initialization messages. Fix it by using dev_info.
> 
> Found and tested on real hardware.
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

Applied to net-next-2.6, thanks.
