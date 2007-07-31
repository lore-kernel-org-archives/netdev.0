From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH 3/3] PPPoE: move lock_sock() in pppoe_sendmsg()
 to the right location
Date: Mon, 30 Jul 2007 17:49:43 -0700 (PDT)
Message-ID: <20070730.174943.11385786.davem@davemloft.net>
References: <20070729060446.GC27573@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@earthlink.net, netdev@vger.kernel.org
To: florz@florz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934971AbXGaAto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:49:44 -0400
In-Reply-To: <20070729060446.GC27573@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Sun, 29 Jul 2007 08:04:46 +0200

> and the last one for now: Acquire the sock lock in pppoe_sendmsg()
> before accessing the sock - and in particular avoid releasing the lock
> even though it hasn't been acquired.
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>

Also applied, thanks Florian.
