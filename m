From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 06:37:41 +0200
Message-ID: <1340080661.7491.2205.camel@edumazet-glaptop>
References: <20120618.211539.105938285016510975.davem@davemloft.net>
	 <1340079813.7491.2164.camel@edumazet-glaptop>
	 <1340079938.7491.2172.camel@edumazet-glaptop>
	 <20120618.212721.2148947025741866390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35490 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2FSEhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:37:45 -0400
Received: by eaak11 with SMTP id k11so1807489eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:37:44 -0700 (PDT)
In-Reply-To: <20120618.212721.2148947025741866390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 21:27 -0700, David Miller wrote:

> How are we not using it?  We use the cached SKB socket no matter what
> happens.
> 
> Look at how inet hash lookup works.
> 
> The error tells the caller solely whether a route lookup is still
> necessary.

OK, remove the unlikely() in __inet_lookup_skb() so that its obvious we
have this skb_steal_sock() thing :)
