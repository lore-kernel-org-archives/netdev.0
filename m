From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] pxa168_eth: remove unneeded null check
Date: Tue, 24 Aug 2010 14:50:42 -0700 (PDT)
Message-ID: <20100824.145042.102566553.davem@davemloft.net>
References: <20100824165150.GH29330@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssanap@marvell.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab0HXVuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:50:25 -0400
In-Reply-To: <20100824165150.GH29330@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 24 Aug 2010 18:52:46 +0200

> "pep->pd" isn't checked consistently in this function.  For example it's
> dereferenced unconditionally on the next line after the end of the if
> condition.  This function is only called from pxa168_eth_probe() and
> pep->pd is always non-NULL so I removed the check.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
