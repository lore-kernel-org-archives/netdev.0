From: kuznet@ms2.inr.ac.ru
Subject: Re: snd_cwnd drawn and quartered
Date: Wed, 15 Jan 2003 21:43:29 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301151843.VAA16069@sex.inr.ac.ru>
References: <20030115152504.B1521@almesberger.net>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: wa@almesberger.net (Werner Almesberger)
In-Reply-To: <20030115152504.B1521@almesberger.net> from "Werner Almesberger" at Jan 15, 3 03:25:04 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Am I reading this right ?

Yes, most likely. Dumb me understood you finally. :-)

We receive some amount of dupacks for segments >high_seq, before ACK
for retransmitted 99th segment arrives and terminates recovery. You meaned
this, right? :-)

Yup, this is bug. OK, this case is sorted out. I think that small fix
proposed by you is enough for beginning.

Ough... another weirdness with cwand drained to 1 still remains.

Alexey
