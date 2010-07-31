From: David Miller <davem@davemloft.net>
Subject: Re: [patch] dnet: fixup error handling in initialization
Date: Fri, 30 Jul 2010 23:29:06 -0700 (PDT)
Message-ID: <20100730.232906.48506176.davem@davemloft.net>
References: <20100729082729.GS26313@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com, elendil@planet.nl,
	richard.cochran@omicron.at, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755151Ab0GaG2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:28:48 -0400
In-Reply-To: <20100729082729.GS26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 29 Jul 2010 10:27:29 +0200

> There were two problems here.  We returned success if dnet_mii_init()
> failed and there was a release_mem_region() missing.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
