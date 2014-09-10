From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net-timestamp: optimize sock_tx_timestamp
 default path
Date: Tue, 09 Sep 2014 17:35:14 -0700 (PDT)
Message-ID: <20140909.173514.1980043681632801404.davem@davemloft.net>
References: <1410220738-6395-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaIJAfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:35:15 -0400
In-Reply-To: <1410220738-6395-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon,  8 Sep 2014 19:58:58 -0400

> Few packets have timestamping enabled. Exit sock_tx_timestamp quickly
> in this common case.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
