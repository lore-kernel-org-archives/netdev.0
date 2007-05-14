From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LAST CALL] [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Mon, 14 May 2007 12:40:12 +0200
Message-ID: <46483C8C.5040403@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost> <1179066518.15622.60.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35060 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755596AbXENKmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 06:42:33 -0400
In-Reply-To: <1179066518.15622.60.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Ok, I am upgrading this to last call after taking in Patricks feedback.
> Speak now - or send patches against it later. 
> Dave, just let it simmer down for a day or two, then if no complaints,
> go ahead and apply it. It is against net-2.6
> Many thanks to Thomas, Peter and Patrick for their reviews.


Two final suggestions, sorry for not mentioning this earlier.

> +			printk(KERN_DEBUG
> +			       "Dead loop on netdevice %s, fix it urgently!\n",
> +			       dev->name);

> +	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
> +		printk(KERN_DEBUG " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);


For both of these KERN_WARNING or above seems to make sense so
the messages don't end up in some debug log. Please also fix
whitespace and line length for the second printk if you're
going to change this :)
