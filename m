From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 17:04:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928170420.7f8a6612.davem@davemloft.net>
References: <20040923164149.5368d291.davem@davemloft.net>
	<E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
	<20040927025048.GA6723@gondor.apana.org.au>
	<20040926210029.22750d47.davem@davemloft.net>
	<20040927054541.GA8858@gondor.apana.org.au>
	<20040927120154.09fdcadf.davem@davemloft.net>
	<20040927213233.GC7243@gondor.apana.org.au>
	<20040928141002.164c60af.davem@davemloft.net>
	<20040928213415.GA4646@wotan.suse.de>
	<20040928145345.2530d30e.davem@davemloft.net>
	<20040928223344.GC2975@wotan.suse.de>
	<20040928155706.65405e88.davem@davemloft.net>
	<20040929012757.5d0dff61.ak@suse.de>
	<20040928163509.624a748b.davem@davemloft.net>
	<20040929015534.3b39b720.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929015534.3b39b720.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 01:55:34 +0200
Andi Kleen <ak@suse.de> wrote:

> Hmpf, it stopped crashing after I recompiled without -funit-at-a-time
> Maybe it is some compiler issue.

Could be, I was studying all of the retransmit queue state
handling and tried to find some hole in the TSO case and I
could not do so.
