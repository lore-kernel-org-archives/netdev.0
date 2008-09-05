From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] pkt_sched: Fix qdisc state in net_tx_action()
Date: Sat, 6 Sep 2008 01:41:17 +0300
Message-ID: <200809060141.17121.denys@visp.net.lb>
References: <20080905082915.GA7320@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:33820 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbYIEWmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 18:42:35 -0400
In-Reply-To: <20080905082915.GA7320@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 05 September 2008, Jarek Poplawski wrote:
> ------------>
>
> pkt_sched: Fix qdisc state in net_tx_action()
>
> net_tx_action() can skip __QDISC_STATE_SCHED bit clearing while qdisc
> is neither ran nor rescheduled, which may cause endless loop in
> dev_deactivate().
>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Tested, working fine, bug fixed.


