From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 21:09:00 -0400
Message-ID: <6afda9c168e2105c783eec268fc225b4@psc.edu>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0505171612440.3335@linux.site> <20050517232556.GA26846@gondor.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Arthur Kepner <akepner@sgi.com>, dlstevens@us.ibm.com,
        rick.jones2@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050517232556.GA26846@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On May 17, 2005, at 7:25 PM, Herbert Xu wrote:
>
> Perhaps you misunderstood what I was saying.  I meant are there any
> extant systems that would transmit 1 set of fragments to host A with
> id x, then 65535 packets host B, and then wrap around and send a new
> set of fragments to host A with idx.
>
> Linux will never do this thanks to inetpeer.c.

Of course (as usual) NATs break everything. ;-)

There are also the ugly case where fragments could be delayed in the 
network for a period of time, for example during a path change, and 
show up at exactly the wrong time.

   -John
