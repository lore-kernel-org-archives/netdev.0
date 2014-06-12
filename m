From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 11:06:11 -0700 (PDT)
Message-ID: <20140612.110611.584155630422154338.davem@davemloft.net>
References: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402585712-12103-1-git-send-email-per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, panweiping3@gmail.com, nanditad@google.com,
	netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	sergei.shtylyov@cogentembedded.com
To: per.hurtig@kau.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaFLSGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 14:06:12 -0400
In-Reply-To: <1402585712-12103-1-git-send-email-per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Per Hurtig <per.hurtig@kau.se>
Date: Thu, 12 Jun 2014 17:08:32 +0200

> Fix to a problem observed when losing a FIN segment that does not
> contain data.  In such situations, TLP is unable to recover from
> *any* tail loss and instead adds at least PTO ms to the
> retransmission process, i.e., RTO = RTO + PTO.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>

Applied, thanks.
