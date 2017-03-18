From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Sat, 18 Mar 2017 11:32:45 -0600
Message-ID: <e643b82c330eabfa0cef21c480eb6c2c@codeaurora.org>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
 <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
 <CALx6S340TYEFDAbQfG6X4P0tPJWvyxyXpnLgp9JY7UoBuPEJVA@mail.gmail.com>
 <1489191742.28631.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36eXpOn70paFnkSyafMkF7Q=MQWJKKb2=d6+hNpK-8V8A@mail.gmail.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:56306 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdCRRdQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 13:33:16 -0400
In-Reply-To: <CALx6S36eXpOn70paFnkSyafMkF7Q=MQWJKKb2=d6+hNpK-8V8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> All these hypotheses are quite testable, and it should be obvious that
> if a patch is supposed to improve performance there should be some
> effort to quantify the impact.

Hi Tom

I ran a single stream unconnected UDPv4 test on an ARM64 system and I 
see
a slight increase in performance (782 -> 788Mbps) with udp demux 
disabled.
A rudimentary app which does a sendto/recvfrom along with some
statistics collection was used for this.
