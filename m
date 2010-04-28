From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/sb1250: register mdio bus in probe
Date: Wed, 28 Apr 2010 14:32:30 -0700 (PDT)
Message-ID: <20100428.143230.214243747.davem@davemloft.net>
References: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
	<20100427.155215.228945283.davem@davemloft.net>
	<20100428195701.GA3461@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: sebastian@breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47614
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757126Ab0D1VcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:32:24 -0400
In-Reply-To: <20100428195701.GA3461@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Date: Wed, 28 Apr 2010 21:57:01 +0200

> "ifconfig eth0 up && ifconfig eth0 down" triggers:
 ...
> mdiobus_register() calls device_register() which initializes the kobj of
> the device. mdiobus_unregister() calls only device_del() so we have one
> reference left. That one is leaving with mdiobus_free() which is only
> called on remove.
> Since I don't see any reason why mdiobus_register()/mdiobus_unregister()
> should happen in ->open()/->close() I move them to probe & exit.
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

This looks a lot better, applied, thanks Sebastian!
