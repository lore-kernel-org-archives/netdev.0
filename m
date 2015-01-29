From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: ipv4: initialize unicast_sock sk_pacing_rate
Date: Wed, 28 Jan 2015 23:25:24 -0800 (PST)
Message-ID: <20150128.232524.1012570968554386726.davem@davemloft.net>
References: <1422452831.29618.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbbA2HZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:25:25 -0500
In-Reply-To: <1422452831.29618.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Jan 2015 05:47:11 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When I added sk_pacing_rate field, I forgot to initialize its value
> in the per cpu unicast_sock used in ip_send_unicast_reply()
> 
> This means that for sch_fq users, RST packets, or ACK packets sent
> on behalf of TIME_WAIT sockets might be sent to slowly or even dropped
> once we reach the per flow limit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 95bd09eb2750 ("tcp: TSO packets automatic sizing")

Applied and queued up for -stable, thanks.
