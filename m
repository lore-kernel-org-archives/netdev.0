From: rick jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 17:29:16 -0800
Message-ID: <67e9e71a41cc2a840cc89f836e2b6f4b@hp.com>
References: <0525M9211@server5.heliogroup.fr> <420D37A3.6020209@hp.com> <20050211170958.17fcde21.davem@davemloft.net> <20050212143105.GB27456@yakov.inr.ac.ru> <86de38db09518ced8865af09cd79c064@hp.com> <20050212205617.GA29146@yakov.inr.ac.ru> <0db5e06aa50422877f9ec4a2e35d6795@hp.com> <20050212220010.GA29417@yakov.inr.ac.ru>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, hubert.tonneau@fullpliant.org, shemminger@osdl.org
In-Reply-To: <20050212220010.GA29417@yakov.inr.ac.ru>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Feb 12, 2005, at 2:00 PM, Alexey Kuznetsov wrote:
> Any which follows some of congestion window validation recommendations.

If you could point me at the chapter and verse that would be great.

> Even canonical bsd restarts slow start after rtt.

Did we have >= one RTT of idle in the packet trace?

>> N is something other than one though.
>
> Well, 1 is quite enough to be sure that something is very wrong.
> You see a proof here.

The debate of course is what :)

In and of _itself_, a delayed ACK does not guarantee something is very 
wrong.  For example, in a request/response situation when the response 
takes longer than the delayed ACK interval to generate.  And if it was 
not request/response, and the sender simply didn't have any more to 
send at that point.

Going back to the quantity of cwnd which may be left unused when TSO is 
enabled.  If when TSO is enabled, the sender does not take full 
advantage of the cwnd doesn't that then mean that to deal with the same 
bandwidth delay product, one needs a larger TCP window when TSO is 
enabled than when it is not?  In the default case of 
tcp_tso_win_divisor being 8 that would be another 12.5% right?

rick jones
there is no rest for the wicked, yet the virtuous have no pillows
