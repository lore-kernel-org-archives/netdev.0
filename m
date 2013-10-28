From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Mon, 28 Oct 2013 00:58:11 -0400 (EDT)
Message-ID: <20131028.005811.1019765125573743315.davem@davemloft.net>
References: <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	<1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
	<1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab3J1E6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:58:13 -0400
In-Reply-To: <1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Oct 2013 18:25:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While investigating on a recent vxlan regression, I found veth
> was using a zero features set for vxlan tunnels.
> 
> We have to segment GSO frames, copy the payload, and do the checksum.
> 
> This patch brings a ~200% performance increase
> 
> We probably have to add hw_enc_features support
> on other virtual devices.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
