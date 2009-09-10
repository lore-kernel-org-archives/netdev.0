From: David Miller <davem@davemloft.net>
Subject: Re: net_sched: fix estimator lock selection for mq child qdiscs
Date: Wed, 09 Sep 2009 18:11:42 -0700 (PDT)
Message-ID: <20090909.181142.130068809.davem@davemloft.net>
References: <4AA7D0C5.9080601@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35614
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752891AbZIJBL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:11:26 -0400
In-Reply-To: <4AA7D0C5.9080601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 09 Sep 2009 17:59:01 +0200

>     net_sched: fix estimator lock selection for mq child qdiscs
>     
>     When new child qdiscs are attached to the mq qdisc, they are actually
>     attached as root qdiscs to the device queues. The lock selection for
>     new estimators incorrectly picks the root lock of the existing and
>     to be replaced qdisc, which results in a use-after-free once the old
>     qdisc has been destroyed.
>     
>     Mark mq qdisc instances with a new flag and treat qdiscs attached to
>     mq as children similar to regular root qdiscs.
>     
>     Additionally prevent estimators from being attached to the mq qdisc
>     itself since it only updates its byte and packet counters during dumps.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks!
