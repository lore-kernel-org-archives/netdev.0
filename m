From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 05:12:11 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140212.FAA10465@sex.inr.ac.ru>
References: <Pine.LNX.4.33L0.0301131752020.26396-100000@orchestra.cs.caltech.edu>
Mime-Version: 1.0
Cc: wa@almesberger.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chengjin@cs.caltech.edu (Cheng Jin)
In-Reply-To: <Pine.LNX.4.33L0.0301131752020.26396-100000@orchestra.cs.caltech.edu> from "Cheng Jin" at Jan 13, 3 05:58:07 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I am not sure what you mean here, slow start takes much faster to
> transmit 100 pkts than 100 RTTs.  Maybe there is a misunderstanding here,
> when cwnd=1 in congestion recovery, it will stay at 1 until it exits
> recovery unless some packet times out first.

I see! Seems, you spotted a real problem. I missed this.

I feel we should add a trigger stopping such "fast" :-) restransmit
when cwnd falls low. Maybe, the same <cwnd/4 is good criterium.
I need to think, the situation is really weird.

Could you, please, prepare a demo pseudo-tcpdump with your simulator?

> just curious if people can come up with better ways to set cwnd.

Come up! :-)

Alexey
