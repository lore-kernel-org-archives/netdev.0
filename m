From: Thomas Graf <tgraf@suug.ch>
Subject: Re: take 2 WAS (RE: [RFC] make qdisc_restart more readable
Date: Sat, 12 May 2007 11:46:29 +0200
Message-ID: <20070512094629.GJ521@postel.suug.ch>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com> <1178911773.4126.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33545 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754857AbXELJqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 05:46:09 -0400
Content-Disposition: inline
In-Reply-To: <1178911773.4126.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2007-05-11 15:29
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> +	netif_schedule(dev);
> +	return 0;
> +}
> +
> +static struct sk_buff *
> +try_get_tx_pkt(struct net_device *dev, struct Qdisc *q)
> +{
> +	struct sk_buff *skb = NULL;
> +
> +	if (skb = dev->gso_skb) 

This must have caused a warning and you probably want to inline
this function.
