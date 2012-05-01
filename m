From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Mon, 30 Apr 2012 21:03:35 -0400 (EDT)
Message-ID: <20120430.210335.1697570355622765079.davem@davemloft.net>
References: <1335823049.20866.48.camel@pasglop>
	<4F9F12ED.1090009@googlemail.com>
	<1335831987.20866.93.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335831987.20866.93.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 01 May 2012 10:26:27 +1000

> I don't see a good way to sort that out other than introducing a new
> kernel-side structure, change the sockopt number, and support the old
> one as backward binary compat, but that's gross.

First there are no padding issues, compat or otherwise.

Second, there is no reason to add a new data-structure.  Just make
them use the right one, sock_fprog, if they are making the socket
option call themselves.

I can't believe this discussion is still going on, there is nothing to
talk about.
