From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 05:41:25 +0200
Message-ID: <46550965.5000400@trash.net>
References: <1179972902.4082.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Peter P <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Auke <auke-jan.h.kok@intel.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56287 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758513AbXEXDom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 23:44:42 -0400
In-Reply-To: <1179972902.4082.63.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> +	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
> +		printk(KERN_DEBUG " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);


This seems to be based on an old version, your latest patch
changed this to KERN_WARNING.
