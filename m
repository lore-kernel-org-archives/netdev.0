From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 12:42:45 +0300
Message-ID: <201004211242.45988.cratiu@ixiacom.com>
References: <20100421070737.GA30517@gondor.apana.org.au> <20100421.004922.193694715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:10358 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753830Ab0DUJmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 05:42:50 -0400
In-Reply-To: <20100421.004922.193694715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 April 2010 10:49:22 David Miller wrote:
> I put this into net-2.6 and modified the commit message since, as we
> found, this incorrect transport header reset was added there to fix
> IPSEC.
> 
> I'm convinced that Cosmin didn't test the patch he actually sent out
> 
> :-)

I apologize. I've tested the patch on 2.6.7 (tcp_v6_send_ack then) and then 
redid the patch half-asleep against net-next.

Cosmin.
