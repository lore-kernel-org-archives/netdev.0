From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netpoll: Introduce netpoll_carrier_timeout kernel
 option
Date: Wed, 08 Jul 2009 11:11:24 -0700 (PDT)
Message-ID: <20090708.111124.89927283.davem@davemloft.net>
References: <20090708010030.GA26331@oksana.dev.rtsoft.ru>
	<20090707180354.2f203648@nehalam>
	<20090708013011.GA30330@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755935AbZGHSLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 14:11:21 -0400
In-Reply-To: <20090708013011.GA30330@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 8 Jul 2009 05:30:11 +0400

> Some PHYs require longer timeouts for carrier detection, and
> auto-negotiation process may take indefinite amount of time.
> 
> It may be inconvenient to force longer timeouts for sane PHYs,
> so let's introduce a kernel command line option.
> 
> Since we're using module_param(), the option also can be
> changed in runtime.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Seems reasonable, applied to net-next-2.6, thanks.
