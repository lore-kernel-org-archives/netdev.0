From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: free packet_rollover after
 synchronize_net
Date: Tue, 16 Jun 2015 12:19:30 -0700
Message-ID: <1434482370.27504.196.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434473497-28551-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34336 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848AbbFPTTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 15:19:33 -0400
Received: by iebmu5 with SMTP id mu5so19604510ieb.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 12:19:32 -0700 (PDT)
In-Reply-To: <1434473497-28551-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-16 at 12:51 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Destruction of the po->rollover must be delayed until there are no
> more packets in flight that can access it. The field is destroyed in
> packet_release, before synchronize_net. Delay using rcu.
> 
> Fixes: 0648ab70afe6 ("packet: rollover prepare: per-socket state")
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
