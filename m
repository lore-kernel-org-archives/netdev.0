From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 17:06:55 -0700
Message-ID: <428A871F.1000308@us.ibm.com>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0505171612440.3335@linux.site> <20050517232556.GA26846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arthur Kepner <akepner@sgi.com>, dlstevens@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050517232556.GA26846@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>>>Such systems would be violating the spirit of RFC791 which says:
>>>
>>>    The identification field is used to distinguish the fragments of one
>>>    datagram from those of another.  The originating protocol module of
>>>    an internet datagram sets the identification field to a value that
>>>    must be unique for that source-destination pair and protocol for the
>>>    time the datagram will be active in the internet system.
>>>
>>>Are you aware of any extant systems that do this?
>>>....
>>
>>Are you aware of any (new) systems that _don't_ violate this? I 
>>wouldn't want to own one of them! 
> 
> 
> Perhaps you misunderstood what I was saying.  I meant are there any
> extant systems that would transmit 1 set of fragments to host A with
> id x, then 65535 packets host B, and then wrap around and send a new
> set of fragments to host A with idx.
> 
> Linux will never do this thanks to inetpeer.c.

Actually, it depends on which Linux you are using.

Mainline linux certainly has this (per-inetpeer ip_id) - but
at least one distro did not (use inetpeer) :). Not sure
what the current situation is.

Of course, if all the traffic is on the same connection
(which isn't out of the ordinary) would still come down
to the same thing...

thanks,
Nivedita
