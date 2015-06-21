From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] packet: avoid out of bounds read in round robin
 fanout
Date: Sun, 21 Jun 2015 10:27:15 -0700 (PDT)
Message-ID: <20150621.102715.802759820433121518.davem@davemloft.net>
References: <55816378.1020602@cogentembedded.com>
	<1434571174-8356-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbbFURP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 13:15:29 -0400
In-Reply-To: <1434571174-8356-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 17 Jun 2015 15:59:34 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> PACKET_FANOUT_LB computes f->rr_cur such that it is modulo
> f->num_members. It returns the old value unconditionally, but
> f->num_members may have changed since the last store. Ensure
> that the return value is always < num.
> 
> When modifying the logic, simplify it further by replacing the loop
> with an unconditional atomic increment.
> 
> Fixes: dc99f600698d ("packet: Add fanout support.")
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.
