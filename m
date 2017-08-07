From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] IP: cleanup LSRR option processing
Date: Sun, 06 Aug 2017 20:51:29 -0700 (PDT)
Message-ID: <20170806.205129.1670918839619898846.davem@davemloft.net>
References: <cover.1501775813.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdHGDva (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 23:51:30 -0400
In-Reply-To: <cover.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu,  3 Aug 2017 18:07:04 +0200

> The __ip_options_echo() function expect a valid dst entry in skb->dst;
> as result we sometimes need to preserve the dst entry for the whole IP
> RX path.
> 
> The current usage of skb->dst looks more a relic from ancient past that
> a real functional constraint. This patchset tries to remove such usage,
> and than drops some hacks currently in place in the IP code to keep
> skb->dst around.
> 
> __ip_options_echo() uses of skb->dst for two different purposes: retrieving
> the netns assicated with the skb, and modify the ingress packet LSRR address
> list. 
> 
> The first patch removes the code modifying the ingress packet, and the second
> one provides an explicit netns argument to __ip_options_echo(). The following
> patches cleanup the current code keeping arund skb->dst for __ip_options_echo's
> sake.
> 
> Updating the __ip_options_echo() function has been previously discussed here:
> 
> http://marc.info/?l=linux-netdev&m=150064533516348&w=2

Series applied, thanks.
