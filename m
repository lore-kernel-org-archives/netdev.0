From: David Miller <davem@davemloft.net>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 14:11:27 -0500 (EST)
Message-ID: <20170112.141127.426662758858102403.davem@davemloft.net>
References: <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
        <1484246584.4651.3.camel@redhat.com>
        <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, stephen@networkplumber.org, netdev@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdALTL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 14:11:29 -0500
In-Reply-To: <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 12 Jan 2017 20:02:14 +0100

> But what about fetching the list of all existing peers and ipmasks
> atomically? It seems like with multiple calls, if I'm using some kind
> of pagination, things could change in the process. That's why using
> one big buffer was most appealing... Any ideas about this?

This is a fact of life, dumps are always chopped into suitable
numbers of responses as necessary.  We do this for IPV4 routes,
network interfaces, etc. and it all works out just fine.

The thing you should be asking yourself is, if something as heavily
used and fundamental as IPV4 can handle this, probably your scenerio
can be handled just fine as well.
