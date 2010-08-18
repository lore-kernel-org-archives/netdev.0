From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/sched: remove unneeded NULL check
Date: Wed, 18 Aug 2010 14:27:38 -0700 (PDT)
Message-ID: <20100818.142738.48517986.davem@davemloft.net>
References: <20100814210949.GB645@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, jarkao2@gmail.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754468Ab0HRV1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:27:19 -0400
In-Reply-To: <20100814210949.GB645@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 14 Aug 2010 23:09:49 +0200

> There is no need to check "s".  nla_data() doesn't return NULL.  Also we
> already dereferenced "s" at this point so it would have oopsed ealier if
> it were NULL.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
