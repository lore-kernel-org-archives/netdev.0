From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiple queue hardware support
Date: Wed, 20 Jun 2007 14:51:40 -0700 (PDT)
Message-ID: <20070620.145140.124887325.davem@davemloft.net>
References: <200706201658.43820.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	raisch@de.ibm.com, osstklei@de.ibm.com, themann@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbXFTVvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 17:51:22 -0400
In-Reply-To: <200706201658.43820.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Wed, 20 Jun 2007 16:58:43 +0200

> to me it seems that this patch set only include multiple transmit
> queue support (for qdisc). Am I right with this observation? If so,
> are there also plans to support multiple receive queues to allow the
> queues to be processed in parallel on different CPUs via a standard
> interface? Currently, some drivers use "fake netdevices" to feed
> netif_rx_schedule().

Yes.

See the "struct net_poll" patches that went out several months
ago, that will help things out in that area.
