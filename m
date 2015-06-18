From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] packet: avoid out of bounds read in round robin
 fanout
Date: Thu, 18 Jun 2015 04:08:59 -0700
Message-ID: <1434625739.27504.204.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55816378.1020602@cogentembedded.com>
	 <1434571174-8356-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33509 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbFRLJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 07:09:08 -0400
Received: by wgez8 with SMTP id z8so60597240wge.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 04:09:07 -0700 (PDT)
In-Reply-To: <1434571174-8356-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-17 at 15:59 -0400, Willem de Bruijn wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
