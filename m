From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Thu, 15 Jun 2017 17:26:37 -0400 (EDT)
Message-ID: <20170615.172637.978834439625255398.davem@davemloft.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
        <20170615.121806.1737755943471705142.davem@davemloft.net>
        <1497554912.2518.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdFOV0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:26:39 -0400
In-Reply-To: <1497554912.2518.9.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 15 Jun 2017 21:28:32 +0200

> On Thu, 2017-06-15 at 12:18 -0400, David Miller wrote:
> 
>> Although a bit disruptive, it might be nice to convert all of the
>> other "char *" related data pointers in skbuff based interfaces.
> 
> I think it'd actually be pretty easy, since there are very few cases
> where you need non-void, e.g.
> 
> *skb_put(skb, 1) = 'x';
> 
> Seems pretty unlikely we have that, and in any case the compiler would
> warn (error?) there if skb_put() becomes void.

Actually I am pretty sure I've seen a pattern like that somewhere. :-)
