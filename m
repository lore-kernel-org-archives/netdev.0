From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] qlcnic: use standard NAPI weights
Date: Thu, 05 Sep 2013 12:46:06 -0400 (EDT)
Message-ID: <20130905.124606.910539581016843593.davem@davemloft.net>
References: <5217676D.6000608@redhat.com>
	<ADFE82A996F10145934E45547759F763311D183F@avmb3.qlogic.org>
	<52272F89.60505@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, netdev@vger.kernel.org,
	edumazet@google.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com,
	Linux-Driver@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab3IEQqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 12:46:09 -0400
In-Reply-To: <52272F89.60505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Wed, 04 Sep 2013 15:03:05 +0200

> Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
> netif_napi_add() produces an error message if a NAPI poll weight
> greater than 64 is requested.
> 
> qlcnic requests the weight as large as 256 for some of its rings, and
> smaller values for other rings. For instance in qlcnic_82xx_napi_add()
> I think the intention was to give the tx+rx ring a bigger weight than
> to rx-only rings, but it's actually doing the opposite. So I'm assuming
> the weights do not really matter much.
> 
> Just use the standard NAPI weights for all rings.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> Acked-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

Applied.
