From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 19:31:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921173134.GC12132@wotan.suse.de>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org> <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> <20040922.010428.104988024.yoshfuji@linux-ipv6.org> <1095784761.3934.52.camel@tim.rtg.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Gardner <timg@tpi.com>
Content-Disposition: inline
In-Reply-To: <1095784761.3934.52.camel@tim.rtg.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I've developed a variant of the Port Scan Detector (PSD) iptables filter
> that combats this very problem. It only allows so many destination
> IP/Port pairs from a given address to be opened over time. This limits
> the rate at which connections can be opened as well as the absolute
> number. For example, on my edge routers I set the policy that no single
> IP source address can create more then 64 connections within a 30 second
> sliding window. This has made a huge impact on the ARP storms that our
> network used to experience.

But also allows an easy DOS. Someone just has to spoof a lot of connections
attempts with the source address of your primary name server or 
some other important service.

-Andi
