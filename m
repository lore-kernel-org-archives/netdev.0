From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.6-rt: inet_sk_rx_dst_set() network splat
Date: Wed, 24 Apr 2013 22:03:53 -0700
Message-ID: <1366866233.8964.128.camel@edumazet-glaptop>
References: <1366786204.5977.10.camel@marge.simpson.net>
	 <1366853695.8964.120.camel@edumazet-glaptop>
	 <1366865490.4595.22.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	RT <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mike Galbraith <bitbucket@online.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1366865490.4595.22.camel@marge.simpson.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-25 at 06:51 +0200, Mike Galbraith wrote:

> Thanks for the fix.  I'll apply it and beat on the box some more (g.p.).
> Gripe only happened the one time during long workout day.

To force it to happen, you need to invalidate the cached dst in socket.

So presumably doing in the background some "ip ro ..." commands to
add/delete routes.

Then prequeue happens if you use a program blocking on receive (not
using poll()/select()/epoll())



