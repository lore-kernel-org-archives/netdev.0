From: David Miller <davem@davemloft.net>
Subject: Re: [patch] atm: iphase: off by one in rx_pkt()
Date: Tue, 31 May 2016 11:53:18 -0700 (PDT)
Message-ID: <20160531.115318.1748170211000331540.davem@davemloft.net>
References: <20160527103435.GB3255@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbcEaSxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:53:19 -0400
In-Reply-To: <20160527103435.GB3255@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 27 May 2016 13:34:35 +0300

> The iadev->rx_open[] array holds "iadev->num_vc" pointers (this code
> assumes that pointers are 32 bits).  So the > here should be >= or else
> we could end up reading a garbage pointer from one element beyond the
> end of the array.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
