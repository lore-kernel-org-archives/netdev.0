From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Sat, 18 Mar 2017 20:07:22 -0600
Message-ID: <c965b4cc8b5f81cc17836f91423935f5@codeaurora.org>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
 <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
 <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
 <1489191742.28631.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36eXpOn70paFnkSyafMkF7Q=MQWJKKb2=d6+hNpK-8V8A@mail.gmail.com>
 <e643b82c330eabfa0cef21c480eb6c2c@codeaurora.org>
 <CALx6S343iWzOKrKwHquG8qmyLyKOgQr_KroHyypE_9MFt2+1BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45572 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdCSCIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 22:08:43 -0400
In-Reply-To: <CALx6S343iWzOKrKwHquG8qmyLyKOgQr_KroHyypE_9MFt2+1BQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Less than 1% performance improvement in a benchmark doesn't justify
> the complexity of the patch. Eric's hypothesis was that an unconnected
> UDP socket may show issues because of cache misses in look-ups due to
> so many different sources. This should be fairly easy to benchmark by
> randomly setting source address in your test (IP any and routing my
> need to be set appropriately).
> 

With different source addresses, a larger increase is seen here
(633->654Mbps).
