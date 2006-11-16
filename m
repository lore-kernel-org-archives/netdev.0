From: David Miller <davem@davemloft.net>
Subject: Re: IPv4: ip_options_compile() how can we avoid blowing up on a
 NULL skb???
Date: Thu, 16 Nov 2006 18:47:30 -0500 (EST)
Message-ID: <20061116.184730.35014107.davem@davemloft.net>
References: <9a8748490611161434oc393db0o1e1c23ba99b1c796@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:1208 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1424600AbWKPXrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 18:47:31 -0500
To: jesper.juhl@gmail.com
In-Reply-To: <9a8748490611161434oc393db0o1e1c23ba99b1c796@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Thu, 16 Nov 2006 23:34:14 +0100

> So if 'skb' is NULL, the only route I see that doesn't cause a NULL
> pointer deref is if  (opt != NULL)  and at the same time
> (opt->is_data != NULL)  .   Is that guaranteed in any way?

Yes, it is guarenteed, all callers  make sure these invariants
hold true.

I'm very happy to accept a patch which assert's this using BUG()
checks :-)
