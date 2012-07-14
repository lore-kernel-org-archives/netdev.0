From: Willy Tarreau <w@1wt.eu>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 16:56:36 +0200
Message-ID: <20120714145636.GS16256@1wt.eu>
References: <20120713171835.GA26052@vault.local> <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com> <1342254042.3265.9017.camel@edumazet-glaptop> <CAJd=RBAJOqJDSBpaaB+2-WU_pa5vChXSf6TbLH8fi3HNt6hZ9w@mail.gmail.com> <1342275540.3265.9760.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hillf Danton <dhillf@gmail.com>,
	Johannes Truschnigg <johannes@truschnigg.info>,
	linux-kernel@vger.kernel.org, Linux-Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4740 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab2GNO4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 10:56:44 -0400
Content-Disposition: inline
In-Reply-To: <1342275540.3265.9760.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 04:19:00PM +0200, Eric Dumazet wrote:
> On Sat, 2012-07-14 at 22:08 +0800, Hillf Danton wrote:
> > On Sat, Jul 14, 2012 at 4:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > >
> > > Might be, or not (could be a NIC bug)
> > >
> > Dunno why sendfile sits in the layer of NIC and
> > how they interact.
> 
> sendfile() relies heavily on TSO capabilities, a buggy NIC could
> corrupt frame content on some obscure occasions.
> 
> We had some known cases on IPv6 for example.

Similarly I remind having experienced bugs on early Yukon chips years
ago that would regularly emit total crap on the wire.

Willy
