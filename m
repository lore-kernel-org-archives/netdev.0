From: rick jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 13:43:52 -0800
Message-ID: <0db5e06aa50422877f9ec4a2e35d6795@hp.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <86de38db09518ced8865af09cd79c064@hp.com> <20050212205617.GA29146@yakov.inr.ac.ru>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, romieu@fr.zoreil.com, hubert.tonneau@fullpliant.org,
        shemminger@osdl.org
In-Reply-To: <20050212205617.GA29146@yakov.inr.ac.ru>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> If receiver sent an ACK it still does not mean that sender used it
> to increase its cwnd. Particularly, small packet exchange definitely
> does not inflate cwnd.

Is that in general, or in Linux?

>> output.  All the stacks with ACK avoidance with which I am familiar do
>> not make the assumption that the sender is not doing slow-start.  They
>> make sure to send enough ACKs at the beginning (or after packet loss)
>> to allow the sender's cwnd to grow.
>
> Well, we do similar thing with delayed ACKs. And it took a few of runs
> of testing to understand that we cannot detect even packet loss 
> reliably
> enough. :-)

I never claimed it was easy :)

> Actually, those receivers could use the first delayed ACK event as
> a sign of failure of their heuristics and block stretching acks for
> this connection.

The ones with which I am familiar do - after N delayed ACK events where 
N is something other than one though.  And they still send immediate 
ACKs to the senders upon out of order data and all that.

rick jones
Wisdom teeth are impacted, people are affected by the effects of events
