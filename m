From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 21:28:32 +0200
Message-ID: <1497554912.2518.9.camel@sipsolutions.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <20170615.121806.1737755943471705142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52480 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750801AbdFOT2f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 15:28:35 -0400
In-Reply-To: <20170615.121806.1737755943471705142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 12:18 -0400, David Miller wrote:

> Although a bit disruptive, it might be nice to convert all of the
> other "char *" related data pointers in skbuff based interfaces.

I think it'd actually be pretty easy, since there are very few cases
where you need non-void, e.g.

*skb_put(skb, 1) = 'x';

Seems pretty unlikely we have that, and in any case the compiler would
warn (error?) there if skb_put() becomes void.

> No, I'm not asking you specifically to work on this, relax :)

:-)

johannes
