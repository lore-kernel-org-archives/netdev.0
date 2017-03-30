From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Wed, 29 Mar 2017 20:15:17 -0700 (PDT)
Message-ID: <20170329.201517.300684629549047939.davem@davemloft.net>
References: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
        <1490821714.3177.189.camel@kernel.crashing.org>
        <1490834778.3177.197.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54038 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753613AbdC3DPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 23:15:24 -0400
In-Reply-To: <1490834778.3177.197.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 30 Mar 2017 11:46:18 +1100

> On Thu, 2017-03-30 at 08:08 +1100, Benjamin Herrenschmidt wrote:
>> On Wed, 2017-03-29 at 11:08 -0700, Florian Fainelli wrote:
>> > I hear your point that you are the only users of the driver and
>> > it's
>> > already in a bad shape, but take this as an opportunity to increase
>> > your commit count ;)
>> 
>> Haha, my commit count is fine thanks ;-)
>> 
>> I'll see what I can do. I need to respin anyway, I haven't tested
>> the netpoll support and it doesn't build (ugh). So I'll try to break
>> it down. Maybe not 200 patches but I'll see if I can make it more
>> palatable.
> 
> FYI, Dave, Florian
> 
> I've started re-doing the work in the form of a series of patches.
> 
> I can't promise I'll manage to make them all really small but I'll
> do my best. So hold onto reviewing if you haven't started already.
> 
> The end result will, I hope, be identical.

Thanks for doing this.
