From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 03:54:12 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301140054.DAA09932@sex.inr.ac.ru>
References: <20030102030858.E1363@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net (Werner Almesberger)
In-Reply-To: <20030102030858.E1363@almesberger.net> from "Werner Almesberger" at Jan 2, 3 03:08:58 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> http://www.almesberger.net/misc/quarter.eps

So... recovery is supposed to terminate when snd.una reaches 100
(snd.nxt at beginning of fast retransmit). In this case cwnd would
be orig_cwnd/2, as expected. But it did not stop! Hence, something
extraordinary happened while recovery, which resulted in the second recovery.
But I do not understand why snd_ssthresh was not shrinken too.
All this smells like a bug. I do not see from the picture
what was this. Can you make a pseudo-tcpdump instead of picture?

Alexey
