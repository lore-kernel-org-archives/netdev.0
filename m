From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: update reordering first before detecting
 loss
Date: Wed, 29 Apr 2015 18:13:13 -0400 (EDT)
Message-ID: <20150429.181313.1414453244451621760.davem@davemloft.net>
References: <1430332110-10278-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbD2WNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:13:15 -0400
In-Reply-To: <1430332110-10278-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 29 Apr 2015 11:28:30 -0700

> tcp_mark_lost_retrans is not used when FACK is disabled. Since
> tcp_update_reordering may disable FACK, it should be called first
> before tcp_mark_lost_retrans.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
