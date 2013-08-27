From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] netxen: lower NAPI weight
Date: Tue, 27 Aug 2013 15:00:14 -0400 (EDT)
Message-ID: <20130827.150014.1709406153715866482.davem@davemloft.net>
References: <1377103771-1590-3-git-send-email-mschmidt@redhat.com>
	<521503E5.1080003@cogentembedded.com>
	<52176675.3060202@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	edumazet@google.com, manish.chopra@qlogic.com,
	sony.chacko@qlogic.com, rajesh.borundia@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab3H0TAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 15:00:16 -0400
In-Reply-To: <52176675.3060202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 23 Aug 2013 15:41:09 +0200

> Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
> netif_napi_add() produces an error message if a NAPI poll weight
> greater than 64 is requested.
> 
> Use the standard NAPI weight.
> 
> v2: proper reference to the related commit
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
