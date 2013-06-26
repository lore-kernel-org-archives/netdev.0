From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: rearm router solicitaion timer when
 setting new tokenized address
Date: Wed, 26 Jun 2013 15:23:28 -0700 (PDT)
Message-ID: <20130626.152328.1141921755297274407.davem@davemloft.net>
References: <20130626014149.GB20081@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206Ab3FZWX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:23:29 -0400
In-Reply-To: <20130626014149.GB20081@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 26 Jun 2013 03:41:49 +0200

> When a new tokenized address gets installed we send out just one
> router solicition. We should send out `rtr_solicits' in case one router
> advertisment got lost.
> 
> So, rearm the timer as we do in addrconf_dad_complete.
> 
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
