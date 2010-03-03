From: David Miller <davem@davemloft.net>
Subject: Re: [patch] davinci_emac: off by one
Date: Wed, 03 Mar 2010 01:08:14 -0800 (PST)
Message-ID: <20100303.010814.246406195.davem@davemloft.net>
References: <20100303070724.GC5086@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chaithrika@ti.com, srk@ti.com,
	khilman@deeprootsystems.com, anantgole@ti.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755037Ab0CCJH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 04:07:56 -0500
In-Reply-To: <20100303070724.GC5086@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 3 Mar 2010 10:07:24 +0300

> This off by one error was found by smatch.
> 
> drivers/net/davinci_emac.c +2390 emac_dev_open(13) error: buffer overflow 'priv->mac_addr' 6 <= 6
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> I don't have the hardware to test this.  If would be cool if someone
> would verify that the hardware still works after the patch is applied.

It looks obvious enough for me, taking in more than 6 address
bytes make no sense in an ethernet driver, so I'll apply this.

Thanks.
