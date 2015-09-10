From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] tcp: generate CA_EVENT_TX_START on data frames
Date: Thu, 10 Sep 2015 10:58:56 -0700 (PDT)
Message-ID: <20150910.105856.1968231602083108972.davem@davemloft.net>
References: <1441860877.4619.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	jri@google.com, stephen@networkplumber.org, sangtae.ha@gmail.com,
	lawrence@brakmo.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130AbbIJR7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:59:00 -0400
In-Reply-To: <1441860877.4619.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Sep 2015 21:54:37 -0700

> From: Neal Cardwell <ncardwell@google.com>
> 
> Issuing a CC TX_START event on control frames like pure ACK
> is a waste of time, as a CC should not care.
> 
> Following patch needs this change, as we want CUBIC to properly track
> idle time at a low cost, with a single TX_START being generated.
> 
> Yuchung might slightly refine the condition triggering TX_START
> on a followup patch.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
