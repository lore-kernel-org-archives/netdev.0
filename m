From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4] jme: lower NAPI weight
Date: Tue, 27 Aug 2013 15:00:07 -0400 (EDT)
Message-ID: <20130827.150007.415263358562728850.davem@davemloft.net>
References: <1377103771-1590-2-git-send-email-mschmidt@redhat.com>
	<521503B6.4010105@cogentembedded.com>
	<52176665.2030507@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	edumazet@google.com, cooldavid@cooldavid.org
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab3H0TAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 15:00:10 -0400
In-Reply-To: <52176665.2030507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri, 23 Aug 2013 15:40:53 +0200

> Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
> netif_napi_add() produces an error message if a NAPI poll weight
> greater than 64 is requested.
> 
> jme requests a quarter of the rx ring size as the NAPI weight.
> jme's rx ring size is 1 << 9 = 512.
> 
> Use the standard NAPI weight.
> 
> v2: proper reference to the related commit
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
