From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 12:47:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001124733.1ac4266a.davem@davemloft.net>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
	<20041001121123.19511403.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jheffner@psc.edu, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041001121123.19511403.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004 12:11:23 +0200
Andi Kleen <ak@suse.de> wrote:

> Do you want me to play with the new sysctl too?

Yes.

>      max win adv:            5840 bytes     max win adv:           63712 bytes
>      min win adv:            5840 bytes     min win adv:            5792 bytes

That stinks that the receiver is only using a 64K window,
that's way too small for gigabit.
