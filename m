From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Thu, 07 Apr 2016 18:01:35 -0400 (EDT)
Message-ID: <20160407.180135.564832114209884831.davem@davemloft.net>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbcDHAeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 20:34:46 -0400
In-Reply-To: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  7 Apr 2016 23:53:35 +0200

> I forgot to add inline to lockdep_sock_is_held, so it generated all
> kinds of build warnings if not build with lockdep support.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
