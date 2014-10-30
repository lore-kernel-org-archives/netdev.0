From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: allow for bigger reordering level
Date: Thu, 30 Oct 2014 16:14:17 -0400 (EDT)
Message-ID: <20141030.161417.325550902152268177.davem@davemloft.net>
References: <1414471524.13259.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141029.150624.878155212768758630.davem@davemloft.net>
	<1414610869.631.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wygivan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933358AbaJ3UOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 16:14:19 -0400
In-Reply-To: <1414610869.631.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Oct 2014 12:27:49 -0700

> Yuchung and othres are working on a new way to handle reorders (RACK),
> and should present the concept in next IETF meeting.
> 
> A linux patch should follow shortly.
> 
> High level idea is :
> 
> Decide when and what to retransmit based on the timing, instead of
> sequence, relationships. This covers both original or retransmitted
> packets.
> 
> On dupacks, wait a fraction of RTT before the repair process to both
> allow reordering and relieve the network

My instint says that this delay will increase recovery time, but I
guess they've taken that into consideration :-)
