From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 23:28:28 +0200
Message-ID: <1497562108.2518.12.camel@sipsolutions.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <20170615.121806.1737755943471705142.davem@davemloft.net>
         <1497554912.2518.9.camel@sipsolutions.net>
         <20170615.172637.978834439625255398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53442 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750820AbdFOV2d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 17:28:33 -0400
In-Reply-To: <20170615.172637.978834439625255398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 17:26 -0400, David Miller wrote:
> 
> > *skb_put(skb, 1) = 'x';
> > 
> > Seems pretty unlikely we have that, and in any case the compiler
> would
> > warn (error?) there if skb_put() becomes void.
> 
> Actually I am pretty sure I've seen a pattern like that somewhere. :-
> )

Yeah, there are actually a ton of them, and oddly enough my spatch is
failing to catch _one_ of them?? Still refining it :)

johannes
