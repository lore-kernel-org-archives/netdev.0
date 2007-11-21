From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: is it useful testing __LINK_STATE_RX_SCHED in dev_close()?
Date: Wed, 21 Nov 2007 12:54:16 +0800
Message-ID: <E1IuhbM-0006tD-00@gondolin.me.apana.org.au>
References: <200711210142.AYF83693@topsec.com.cn>
Cc: netdev@vger.kernel.org
To: wyb@topsec.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4891 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752042AbXKUFIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 00:08:25 -0500
In-Reply-To: <200711210142.AYF83693@topsec.com.cn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wyb@topsec.com.cn wrote:
> cpu0 calling netif_rx_schedule_prep(), cpu1 calling dev_close():
> 
> cpu0: testing __LINK_STATE_START, already set
> cpu1: clear__LINK_STATE_START
> cpu1: testing __LINK_STATE_RX_SCHED, not set
> cpu0: set __LINK_STATE_RX_SCHED
> cpu0: enter net poll, ...
> 
> when cpu1 return from dev_close(),__LINK_STATE_RX_SCHED is still set, the
> testing maybe of no use.

Can you please check whether this still happens with the current
kernel since RX_SCHED no longer exists there?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
