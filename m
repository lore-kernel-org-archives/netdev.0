From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:53:48 -0700 (PDT)
Message-ID: <20070612.145348.22503996.davem@davemloft.net>
References: <466F0D78.7090404@candelatech.com>
	<20070612.142658.45082832.davem@davemloft.net>
	<466F142C.4040109@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754794AbXFLVxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:53:31 -0400
In-Reply-To: <466F142C.4040109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 12 Jun 2007 17:46:20 -0400

> Not quite...  You'll have to deal with multiple Rx filters, not just the 
> current one-filter-for-all model present in today's NICs.  Pools of 
> queues will have separate configured characteristics.  The "steer" 
> portion you mention is a bottleneck that wants to be eliminated.

It runs in hardware at wire speed, what's the issue? :-)
