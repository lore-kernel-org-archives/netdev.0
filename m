From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [PATCH] tcp: fix a size_t < 0 comparison in
 tcp_read_sock
Date: Thu, 03 Jul 2008 03:31:30 -0700 (PDT)
Message-ID: <20080703.033130.05399827.davem@davemloft.net>
References: <200807022157.53647.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32977
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755971AbYGCM1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:27:24 -0400
In-Reply-To: <200807022157.53647.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 2 Jul 2008 21:57:53 +0300

> 
> Discovered it while testing this patch:
> 
> http://www.spinics.net/lists/netdev/msg64668.html
> 
> (in this case, tcp_read_sock breaks; but regardless of that patch I think we 
> should have this one)

Applied, thanks a lot!
