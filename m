From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: delete duplicate dev_set_rx_mode() call
Date: Tue, 17 Jun 2014 15:31:45 -0700 (PDT)
Message-ID: <20140617.153145.1029007671961636897.davem@davemloft.net>
References: <cover.1402926490.git.panweiping3@gmail.com>
	<cover.1402926490.git.panweiping3@gmail.com>
	<3b4f2d21523f2a03b21d4dc1350327752c634771.1402926490.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966657AbaFQWbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 18:31:46 -0400
In-Reply-To: <3b4f2d21523f2a03b21d4dc1350327752c634771.1402926490.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Mon, 16 Jun 2014 21:57:22 +0800

> In __dev_open(), it already calls dev_set_rx_mode().
> and dev_set_rx_mode() has no effect for a net device which does not have
> IFF_UP flag set.
> 
> So the call of dev_set_rx_mode() is duplicate in __dev_change_flags().
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Applied.
