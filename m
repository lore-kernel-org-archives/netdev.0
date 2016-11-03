From: David Miller <davem@davemloft.net>
Subject: Re: Time to revisit LISP?
Date: Thu, 03 Nov 2016 17:00:18 -0400 (EDT)
Message-ID: <20161103.170018.314857405677363551.davem@davemloft.net>
References: <CALx6S35cT6gn4W6iiaL5sAgTm=jJPZpyVP3pyGXfbyHHsKaciQ@mail.gmail.com>
        <20161103.163758.1592587767905993803.davem@davemloft.net>
        <CALx6S34-b0dDL0xOvjU+uDzwsZHAt4QPfpHrpeauMmMh4MTKXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@logicalelegance.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbcKCVAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 17:00:20 -0400
In-Reply-To: <CALx6S34-b0dDL0xOvjU+uDzwsZHAt4QPfpHrpeauMmMh4MTKXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 3 Nov 2016 13:57:59 -0700

> On Thu, Nov 3, 2016 at 1:37 PM, David Miller <davem@davemloft.net> wrote:
>> Userspace resolution of paths in response to data path signalling
>> simply does not scale and is fundamentally an extremely poor design
>> choice.  We're trying to move away from, rather than towards, these
>> kinds of architectures.
> 
> OVS is quite different I think. LISP is a specific resolution protocol
> of identifier to locator as opposed to be some open ended mechanism to
> resolve some arbitrary definition of flows like OVS. Also, I don't
> think there's any specific requirement in LISP that prevents on from
> implementing the mapping protocol in the kernel, it should just be a
> simple UDP communication.
> 
> Do you see anything in the protocol itself that would be a showstopper?

I'd have to see the code and how it works.  I can't review hypothetical
implementations.
