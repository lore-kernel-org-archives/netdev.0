From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] sfc: add support for skb->xmit_more
Date: Tue, 14 Oct 2014 17:15:01 -0400 (EDT)
Message-ID: <20141014.171501.448630399243434370.davem@davemloft.net>
References: <543C13AE.80606@solarflare.com>
	<543C2588.6060604@redhat.com>
	<alpine.LFD.2.03.1410141933500.26972@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, nikolay@redhat.com, netdev@vger.kernel.org,
	sshah@solarflare.com, jcooper@solarflare.com,
	linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbaJNVPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 17:15:03 -0400
In-Reply-To: <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 14 Oct 2014 19:41:37 +0100

> Don't ring the doorbell, and don't do PIO.  This will also prevent
>  TX Push, because there will be more than one buffer waiting when
>  the doorbell is rung.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

This looks good to me, mind if I apply this now?
