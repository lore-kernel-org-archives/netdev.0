From: David Miller <davem@davemloft.net>
Subject: Re: [patch] cpmac: use resource_size()
Date: Wed, 30 Jun 2010 13:12:13 -0700 (PDT)
Message-ID: <20100630.131213.199034040.davem@davemloft.net>
References: <20100628211933.GL19184@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, jpirko@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752867Ab0F3UMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:12:00 -0400
In-Reply-To: <20100628211933.GL19184@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 28 Jun 2010 23:19:33 +0200

> The original code is off by one because we should start counting at
> zero.  So the size of the resource is end - start + 1.  I switched it to
> use resource_size() to do the calculation.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied to net-next-2.6, thanks Dan.
