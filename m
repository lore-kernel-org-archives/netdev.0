From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: use GFP_KERNEL in sctp_init()
Date: Tue, 15 Dec 2015 23:28:02 -0500 (EST)
Message-ID: <20151215.232802.1356652749006176104.davem@davemloft.net>
References: <1450222419.8474.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684AbbLPE2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 23:28:04 -0500
In-Reply-To: <1450222419.8474.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Dec 2015 15:33:39 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> modules init functions being called from process context, we better
> use GFP_KERNEL allocations to increase our chances to get these
> high-order pages we want for SCTP hash tables.
> 
> This mostly matters if SCTP module is loaded once memory got fragmented.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
