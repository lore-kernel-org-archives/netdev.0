From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Wed, 15 Jan 2003 20:50:50 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301151750.UAA15907@sex.inr.ac.ru>
References: <20030114033651.S1516@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net (Werner Almesberger)
In-Reply-To: <20030114033651.S1516@almesberger.net> from "Werner Almesberger" at Jan 14, 3 03:36:51 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> This is precisely what NewReno does. If you lose anything within
> that cwnd, recovery is extended.

Werner, where did you get this information? In that case recovery
will not finish. :-)

> 100 refers to high_seq, i.e. the segment we need to get ack'ed
> for leaving recovery.

I still do not understand. Apparently it is based on assumption
of extension of high_seq which must not happen.

> 100:  we've recovered our initial loss, but snd_una is still
>       below high_seq, because of all the other losses in that
>       cwnd

This must not happen. I did not mean this in code and cannot see
how it can happen. high_seq is set once while single recovery cycle.
Something is buggy.

Alexey
