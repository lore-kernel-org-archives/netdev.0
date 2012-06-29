From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] tcp: pass fl6 to inet6_csk_route_req()
Date: Thu, 28 Jun 2012 17:55:26 -0700 (PDT)
Message-ID: <20120628.175526.1054207950870912833.davem@davemloft.net>
References: <1340922861-11684-1-git-send-email-ncardwell@google.com>
	<1340922861-11684-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2F2Az1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 20:55:27 -0400
In-Reply-To: <1340922861-11684-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 28 Jun 2012 15:34:19 -0700

> This commit changes inet_csk_route_req() so that it uses a pointer to
> a struct flowi6, rather than allocating its own on the stack. This
> brings its behavior in line with its IPv4 cousin,
> inet_csk_route_req(), and allows a follow-on patch to fix a dst leak.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
