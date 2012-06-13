From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Wed, 13 Jun 2012 15:35:17 -0700 (PDT)
Message-ID: <20120613.153517.901328280865603627.davem@davemloft.net>
References: <1339581175.22704.342.camel@edumazet-glaptop>
	<1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
	<1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, meravs@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745Ab2FMWfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 18:35:20 -0400
In-Reply-To: <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 13 Jun 2012 16:53:29 +0300

> Just to emphasis, since this is the patch series that enable the users
> to control the number of queues, we can reduce the default number and
> allow the user to increase it if he has a setup that needs more than 8
> parallel CPUs to receive the traffic. When using a new FW on the board,
> the number can be increased up to 64, so using the maximal number can be
> an overkill (even if the machine has 64 CPUs, it does not mean that the
> user would like us to consume 64 MSI-X vectors and all the memory to set
> up 64 queues) - so a lower default value can be used to satisfy most
> users while allowing them to increase the number if they wish.

I think you should look at other drivers for guidance in this area.

There is zero value in each and every driver author deciding what
is a good default strategy, because this means the user gets a
very inconsistent experience based purely upon the driver author's
whims.
