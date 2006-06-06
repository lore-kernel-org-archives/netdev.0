From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:44:01 -0700
Message-ID: <adapshmnbam.fsf@cisco.com>
References: <20060531.170908.46214247.davem@davemloft.net>
	<20060601002525.GA19220@gondor.apana.org.au>
	<20060601111503.GA16097@gondor.apana.org.au>
	<20060605.213250.85688925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:49777 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1750863AbWFFEoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:44:08 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060605.213250.85688925.davem@davemloft.net> (David Miller's message of "Mon, 05 Jun 2006 21:32:50 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > IPOIB is going to BUG() with this change.  Because now, in their
 > multicast code, you're going to local_bh_disable() via
 > netif_tx_unlock() with hw IRQs disabled which is illegal.
 > 
 > It shows a bug here in the locking of the IPOIB driver.

Sorry, I haven't followed this thread closely.  Can you expand on what
the bug in ipoib's multicast locking is?

Thanks,
  Roland
