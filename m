From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Wed, 15 Jan 2003 16:37:11 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030115163711.C1521@almesberger.net>
References: <20030115152504.B1521@almesberger.net> <200301151843.VAA16069@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301151843.VAA16069@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Wed, Jan 15, 2003 at 09:43:29PM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> We receive some amount of dupacks for segments >high_seq, before ACK
> for retransmitted 99th segment arrives and terminates recovery. You meaned
> this, right? :-)

Yes, that's it.

> Yup, this is bug. OK, this case is sorted out. I think that small fix
> proposed by you is enough for beginning.

I think, in addition to this fix, you also need to do RTO upon loss
of retransmission. Otherwise, my fix would make you halve cwnd only
once in this case.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
