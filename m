From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] tcp: introduce a per-route knob for quick
 ack
Date: Wed, 19 Jun 2013 23:07:35 -0700 (PDT)
Message-ID: <20130619.230735.424431851379597627.davem@davemloft.net>
References: <1371260359-5875-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	stephen@networkplumber.org, tgraf@suug.ch, David.Laight@ACULAB.COM
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860Ab3FTGHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 02:07:37 -0400
In-Reply-To: <1371260359-5875-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 15 Jun 2013 09:39:18 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> In previous discussions, I tried to find some reasonable heuristics
> for delayed ACK, however this seems not possible, according to Eric:
 ...
> and according to David:
 ...
> It still makes sense to enable or disable quick ack mode like
> what TCP_QUICK_ACK does.
> 
> Similar to TCP_QUICK_ACK option, but for people who can't
> modify the source code and still wants to control
> TCP delayed ACK behavior. As David suggested, this should belong
> to per-path scope, since different pathes may want different
> behaviors.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
