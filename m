From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: fix races after skb queueing
Date: Fri, 06 Apr 2012 10:34:36 +0200
Message-ID: <1333701276.5312.20.camel@edumazet-glaptop>
References: <1333700266.5312.19.camel@edumazet-glaptop>
	 <20120406.042144.742495137515648292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50505 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab2DFIek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 04:34:40 -0400
Received: by wibhq7 with SMTP id hq7so360625wib.1
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 01:34:39 -0700 (PDT)
In-Reply-To: <20120406.042144.742495137515648292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-06 at 04:21 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 06 Apr 2012 10:17:46 +0200
> 
> > As soon as an skb is queued into socket receive_queue, another thread
> > can consume it, so we are not allowed to reference skb anymore, or risk
> > use after free.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Good catch Eric.
> 
> Applied and queued up for -stable.

Same problem with sock_queue_err_skb(), I'll send a patch for it

Thanks
