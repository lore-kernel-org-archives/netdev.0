From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Thu, 14 Jun 2007 09:49:27 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030A031E@orsmsx414.amr.corp.intel.com>
References: <20070614112111.GB25207@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kumarkr@linux.vnet.ibm.com>, <davem@davemloft.net>,
	<jamal@cyberus.ca>, <tgraf@suug.ch>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:42983 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbXFNQtg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 12:49:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070614112111.GB25207@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> IMHO this scenario occurs so infrequently that the check 
> isn't worth it especially since the driver has to be able to 
> deal with us calling it after netif_stop_queue() anyway.

That sounds just fine to me.  Thanks Krishna and Herbert for weighing in
on this.

-PJ Waskiewicz
