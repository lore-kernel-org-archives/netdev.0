From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: makes syn_ack_timeout mandatory
Date: Sat, 14 Apr 2012 15:29:26 -0400 (EDT)
Message-ID: <20120414.152926.446676650978105923.davem@davemloft.net>
References: <1334304965.5300.8713.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab2DNTad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:30:33 -0400
In-Reply-To: <1334304965.5300.8713.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Apr 2012 10:16:05 +0200

> From: : Eric Dumazet <edumazet@google.com>
> 
> There are two struct request_sock_ops providers, tcp and dccp.
> 
> inet_csk_reqsk_queue_prune() can avoid testing syn_ack_timeout being
> NULL if we make it non NULL like syn_ack_timeout
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
