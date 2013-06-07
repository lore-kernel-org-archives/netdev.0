From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: tcp: move GRO/GSO functions to
 tcp_offload
Date: Fri, 07 Jun 2013 14:39:58 -0700 (PDT)
Message-ID: <20130607.143958.471147906240310925.davem@davemloft.net>
References: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
	<1370617906-4849-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab3FGVj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 17:39:59 -0400
In-Reply-To: <1370617906-4849-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  7 Jun 2013 17:11:46 +0200

> Would be good to make things explicit and move those functions to
> a new file called tcp_offload.c, thus make this similar to tcpv6_offload.c.
> While moving all related functions into tcp_offload.c, we can also
> make some of them static, since they are only used there. Also, add
> an explicit registration function.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
