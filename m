From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 1/3] udp: Only allow busy read/poll on connected
 sockets
Date: Tue, 01 Oct 2013 13:44:47 -0700
Message-ID: <1380660287.19002.36.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-2-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:53352 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3JAUot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 16:44:49 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so7647439pbc.36
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 13:44:48 -0700 (PDT)
In-Reply-To: <1380656025-8847-2-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> UDP sockets can receive packets from multiple endpoints and thus may be
> received on multiple receive queues.  Since packets packets can arrive
> on multiple receive queues we should not mark the napi_id for all
> packets.  This makes busy read/poll only work for connected UDP sockets.
> 
> This additionally enables busy read/poll for UDP multicast packets as
> long as the socket is connected by moving the check into
> __udp_queue_rcv_skb().
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---

Suggested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for following up, it seems I forgot to submit this patch ;)
