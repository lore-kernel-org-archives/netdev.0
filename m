From: dormando <dormando@rydia.net>
Subject: Re: 3 packet TCP window limit?
Date: Wed, 5 May 2010 13:01:19 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1005051239290.28957@d>
References: <alpine.LNX.2.00.1005050210230.8544@d> <4BE171EC.20904@athenacr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([216.218.163.68]:52899 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214Ab0EEUBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 16:01:53 -0400
In-Reply-To: <4BE171EC.20904@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This sounds like TCP slow start.
>
> http://en.wikipedia.org/wiki/Slow-start
>
> As far as tunables you might want to play with the initcwnd route
> flag (see "ip route help")

Ah, yes, initcwnd was it. I'm well aware of TCP Congestion control / slow
start / etc. However I couldn't find the damn tunable for it :)
ssthresh/tso/etc didn't seem to unwedge it. Felt like describing it in the
most generic way possible would help :)

Other OS's appear to have a larger initcwnd. As do commercial load
balancers. The default of 3 seems to be tuned for 56k dialup modems. I'm a
little surprised that none of the pluggable TCP congestion control
algorithms changed this value. I went through all of them except for
tcp_yeah.

Anyway, thanks and sorry for the nearly off-topic post here. I see some
google papers on bumping initcwnd to 10... but I guess that's not linux's
deal yet.
