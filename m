From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Fri, 31 Mar 2017 20:59:27 +1100
Message-ID: <1490954367.3177.236.camel@kernel.crashing.org>
References: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
         <1490821714.3177.189.camel@kernel.crashing.org>
         <1490834778.3177.197.camel@kernel.crashing.org>
         <20170329.201517.300684629549047939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39714 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932875AbdCaJ7x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 05:59:53 -0400
In-Reply-To: <20170329.201517.300684629549047939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 20:15 -0700, David Miller wrote:
> 
> > I've started re-doing the work in the form of a series of patches.
> > 
> > I can't promise I'll manage to make them all really small but I'll
> > do my best. So hold onto reviewing if you haven't started already.
> > 
> > The end result will, I hope, be identical.
> 
> Thanks for doing this.

Alllllright. 2 days and half a night later, we have a 55 patches series
  ...oops ;-)

I did a few things differently from the original patch but overall it's
pretty similar. At least that exercise allowed me to find and fix a
couple of bugs along the way. I hope I didn't introduce twice as
many...

We're running some more testing tonight, if it's all solid I'll shoot
it out tomorrow or sunday. Dave, it's ok to just spam the list with a
55 patches series like that ?

For the curious, if any, it's there along with an unrelated fix for
testing:

https://github.com/ozbenh/linux-ast/commits/upstreaming-work

Cheers,
Ben.
