From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Mon, 07 Sep 2015 17:00:58 -0700 (PDT)
Message-ID: <20150907.170058.1837760587790956754.davem@davemloft.net>
References: <20150906103732.GF30539@calimero.vinschen.de>
	<20150906202153.GB19371@electric-eye.fr.zoreil.com>
	<20150907092949.GH30539@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	pomidorabelisima@gmail.com
To: vinschen@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbIHABC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 20:01:02 -0400
In-Reply-To: <20150907092949.GH30539@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corinna Vinschen <vinschen@redhat.com>
Date: Mon, 7 Sep 2015 11:29:49 +0200

> Still wondering though.  Given that the driver never failed before if
> the counter values couldn't be updated, and given that these counter
> values only have statistical relevance, why should this suddenly result
> in a fatal failure at open time?

Failing to allocate such a small buffer means we have much deeper issues
at hand.  A GFP_KERNEL allocation of this size really should not fail.
