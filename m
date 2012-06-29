From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] tcp: plug dst leak in
 tcp_v6_conn_request()
Date: Thu, 28 Jun 2012 17:55:38 -0700 (PDT)
Message-ID: <20120628.175538.211928125820814739.davem@davemloft.net>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
	<1340922861-11684-4-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab2F2Azj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 20:55:39 -0400
In-Reply-To: <1340922861-11684-4-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 28 Jun 2012 15:34:21 -0700

> The code in tcp_v6_conn_request() was implicitly assuming that
> tcp_v6_send_synack() would take care of dst_release(), much as
> tcp_v4_send_synack() already does. This resulted in
> tcp_v6_conn_request() leaking a dst if sysctl_tw_recycle is enabled.
> 
> This commit restructures tcp_v6_send_synack() so that it accepts a dst
> pointer and takes care of releasing the dst that is passed in, to plug
> the leak and avoid future surprises by bringing the IPv6 behavior in
> line with the IPv4 side.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
