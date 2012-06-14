From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Thu, 14 Jun 2012 13:36:49 -0700 (PDT)
Message-ID: <20120614.133649.794229745961162963.davem@davemloft.net>
References: <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
	<20120613.153517.901328280865603627.davem@davemloft.net>
	<1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756085Ab2FNUgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 16:36:51 -0400
In-Reply-To: <1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Thu, 14 Jun 2012 18:34:06 +0300

> That's why we think (and so does Eric Dumazet) that it is better
> to have a smaller default number which is good for most cases.
> Do you agree with that?

What I think is that the thing which is more important than the
default we choose, is that it is consistently followed by all
multiqueue drivers.

By blazing your own unique path here, that is nearly guaranteed not to
happen.

I'd much rather have a bad default that every driver adheres to.
