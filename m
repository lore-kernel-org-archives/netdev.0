From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 13 Mar 2007 12:32:51 +0300
Message-ID: <20070313093248.GA14221@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru> <20070302085246.GA30951@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43220 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965656AbXCMJd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 05:33:27 -0400
Content-Disposition: inline
In-Reply-To: <20070302085246.GA30951@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 02, 2007 at 11:52:47AM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> So I get my words about tree/trie implementation instead of hash table 
> for socket lookup back.

Hmm, I was a bit fast to draw a line, there are some possibilities to
have faster than hash table lookup using different algorithms...

So, I ask network developers about testing environment for socket lookup
benchmarking. What would be the best test case to determine performance
of the lookup algo? Is it enough to replace algo and locking and create
say one million of connections and try to run trivial web server (that
is what I'm going to test if there will not be any better suggestion,
but I only have single-core athlon 64 with 1gb of ram as a test bed and 
two core duo machines as generators, probably I can use one of them as a
test machine too. They have gigabit adapters and aree connected over 
gigabit switch)?

-- 
	Evgeniy Polyakov
