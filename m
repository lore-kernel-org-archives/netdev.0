From: kuznet@ms2.inr.ac.ru
Subject: Re: packet re-ordering on SMP machines.
Date: Tue, 27 Aug 2002 17:24:24 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208271324.RAA19244@sex.inr.ac.ru>
References: <20020827151317.A3389@wotan.suse.de>
Mime-Version: 1.0
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de (Andi Kleen)
In-Reply-To: <20020827151317.A3389@wotan.suse.de> from "Andi Kleen" at Aug 27, 2 03:13:17 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Moving it later may make it useless for RTT purposes when the queueing 
> delays are too long.

Absolutely wrong. RTT is always calculated end-to-end, otherwise it 
some meaningless quantity, be it sctp, rpc or something.

The only place where precesion of timestamp is more or less interesting
is tcpdump. But not enough to make it not monotonic. :-)

Alexey
