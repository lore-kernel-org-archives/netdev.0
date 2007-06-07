From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 15:44:21 -0700 (PDT)
Message-ID: <20070607.154421.109060486.davem@davemloft.net>
References: <1181219380.4064.55.camel@localhost>
	<46681E41.6060700@intel.com>
	<1181253445.4071.4.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeff@garzik.org, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764124AbXFGWoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 18:44:06 -0400
In-Reply-To: <1181253445.4071.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 07 Jun 2007 17:57:25 -0400

> I empathize but take a closer look; seems mostly useless.

I thought E1000 still uses LLTX, and if so then multiple cpus can most
definitely get into the ->hard_start_xmit() in parallel.
