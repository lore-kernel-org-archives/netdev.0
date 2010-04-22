From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 08:17:33 -0400
Message-ID: <1271938653.4032.33.camel@bigi>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
	 <1271936227.7895.5285.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:55327 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab0DVMRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:17:37 -0400
Received: by qyk9 with SMTP id 9so11111526qyk.1
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 05:17:36 -0700 (PDT)
In-Reply-To: <1271936227.7895.5285.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 13:37 +0200, Eric Dumazet wrote:

> Please reorder things better.
> 
> Most likely this function is called for one packet.
> 
> In your version you take twice the rps_lock()/rps_unlock() path, so
> it'll be slower.
> 
> Once to 'transfert' one list to process list
> 
> Once to be able to do the 'label out:' post processing.
> 

Ok, once it is settled the right changes are i will test.

cheers,
jamal

