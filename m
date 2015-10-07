From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: ensure prior synack rtx behavior with
 small backlogs
Date: Wed, 07 Oct 2015 05:10:01 -0700 (PDT)
Message-ID: <20151007.051001.2204891650276215409.davem@davemloft.net>
References: <1444168198.9555.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbJGLyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:54:17 -0400
In-Reply-To: <1444168198.9555.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Oct 2015 14:49:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Some applications use a listen() backlog of 1.
> 
> Prior kernels were silently enforcing a qlen_log of 4, so that we were
> sending up to /proc/sys/net/ipv4/tcp_synack_retries SYNACK messages.
> 
> Fixes: ef547f2ac16b ("tcp: remove max_qlen_log")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
