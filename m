From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gianfar: Implement workaround for eTSEC74 erratum
Date: Tue, 29 Jun 2010 15:16:26 -0700 (PDT)
Message-ID: <20100629.151626.90794001.davem@davemloft.net>
References: <20100629205959.GA10905@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756172Ab0F2WQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:16:13 -0400
In-Reply-To: <20100629205959.GA10905@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I really don't see any value at all to this config option,
the errata fixup code should be there all the time.

It really does no harm to be there in the cases where it isn't
used, and forcing users to turn this on is just another
obscure way to end up with an incorrect configuration.
