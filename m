From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: net: macb: fail when there's no PHY
Date: Thu, 21 Sep 2017 13:05:57 -0700
Message-ID: <66c0a032-4d20-69f1-deb4-6c65af6ec740@gmail.com>
References: <20170921195905.GA29873@grante>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Grant Edwards <grant.b.edwards@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:38775 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdIUUGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:06:01 -0400
Received: by mail-qk0-f194.google.com with SMTP id c69so4303170qke.5
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:06:01 -0700 (PDT)
In-Reply-To: <20170921195905.GA29873@grante>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2017 12:59 PM, Grant Edwards wrote:
> Several years back (circa 2.6.33) I had to hack up macb.c to work on
> an at91 board that didn't have a PHY connected to the macb controller.
> Now I might need to get a recent kernel version running on that board.
> 
> It looks like the macb driver still can't handle boards that don't
> have a PHY.  Is that correct?

Not since:

dacdbb4dfc1a1a1378df8ebc914d4fe82259ed46 ("net: macb: add fixed-link
node support")

> 
> What's the right way to deal with this?

Declaring a fixed PHY that will present an emulated link UP, with a
fixed speed/duplex etc. is the way to go.

> 
> With the older macb driver, I ended up adding code to macb.c that
> presented a "fake" PHY that discarded MDIO writes and returned some
> hard-wired values for MDIO reads.  That seemed like a pretty ugly way
> to deal with the situation, so I never bothered to submit a patch.
> 

Yeah, no :)
-- 
Florian
