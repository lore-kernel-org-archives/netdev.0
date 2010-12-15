From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Wed, 15 Dec 2010 07:40:32 -0500
Message-ID: <1292416832.2067.13.camel@mojatatu>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f180.google.com ([209.85.214.180]:60732 "EHLO
	mail-iw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab0LOMke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:40:34 -0500
Received: by iwn37 with SMTP id 37so2144686iwn.11
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:40:34 -0800 (PST)
In-Reply-To: <1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 22:43 +0800, Changli Gao wrote:
> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
> 
> We save old queue_mapping in old_queue_mapping just before calling 
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the skb.
> 
> dev_pick_tx() use the current queue_mapping for the skbs reinjected
> by ifb.

You are hard-coding policy here, no? ifb can do a lot of funky things
which change the nature of the flow. I can shape, i can edit packets
etc. Why is the queue mapping any different?

cheers,
jamal

