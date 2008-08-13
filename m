From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 10:42:28 +0000
Message-ID: <20080813104228.GE5367@ff.dom.local>
References: <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local> <20080813.022549.203848195.davem@davemloft.net> <20080813102701.GD5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:57172 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbYHMKmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:42:38 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1048008nfc.21
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 03:42:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813102701.GD5367@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 10:27:01AM +0000, Jarek Poplawski wrote:
...
> - isn't there possible some longer ping-pong between qdic_run() and
> net_tx_action() when dev_requeue_skb() would get it back to
> __netif_schedule() and so on (with NETDEV_TX_BUSY)?

Hmm... I see, after qdisc_reset() it doesn't seem possible to happen.

Jarek P.
