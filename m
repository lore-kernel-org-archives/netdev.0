From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 13:20:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930132031.3264000b.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
	<415B24C0.2020208@us.ibm.com>
	<20040929145050.71afa1ac.davem@davemloft.net>
	<20040929215613.GC26714@wotan.suse.de>
	<20040929162923.796d142e.davem@davemloft.net>
	<20040930000515.GA10496@gondor.apana.org.au>
	<20040929213310.40f5f33a.davem@davemloft.net>
	<20040930092926.GA18353@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ak@suse.de, niv@us.ibm.com, jheffner@psc.edu,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040930092926.GA18353@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 11:29:26 +0200
Andi Kleen <ak@suse.de> wrote:

> Talking to another rc3 kernel with tg3 tso on is as fast as tso off now.
> Unfortunately the ACKs still look funny. 

Can you help us debug this instead of just running tests over
and over Andi?  It's frustrating because I cannot reproduce
the problem here, else I would be adding checks to the receiver
on my systems here. :-/

Please put some checks into the ACK tests on your 2.6.5 receiver
to determine why it does not want to ACK every other frame like
it is supposed to.  We need to figure out where the stretch
ACKs are coming from.

Thanks.
