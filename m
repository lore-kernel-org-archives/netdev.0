From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 19:22:10 +0200
Message-ID: <1342718530.2626.4526.camel@edumazet-glaptop>
References: <20120719.084503.136853790544876708.davem@davemloft.net>
	 <1342717667.2626.4494.camel@edumazet-glaptop>
	 <20120719.101155.1970854797296520147.davem@davemloft.net>
	 <20120719.101225.2227860476502999476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:62579 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab2GSRWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:22:16 -0400
Received: by vcbfk26 with SMTP id fk26so2192989vcb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 10:22:16 -0700 (PDT)
In-Reply-To: <20120719.101225.2227860476502999476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 10:12 -0700, David Miller wrote:

> Just give this thing a unique name and define it right before the function.

Yep, will do that.

I also will init sk_refcnt to one, just in case a driver wants to get a
reference on socket (and free it later).
