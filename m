From: "David S. Miller" <davem@redhat.com>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 10:25:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317102515.6a5f7642.davem@redhat.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
	<1079539766.1034.99.camel@jzny.localdomain>
	<20040317095107.60728e4e.davem@redhat.com>
	<20040317100001.7d33accc@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040317100001.7d33accc@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Mar 2004 10:00:01 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> In an earlier project we had a test suite that failed the Nth allocation,
> then repeated startup failing from 1 till all allocations in a typical
> interaction round trip had been tested.  Sure led to some nasty failures
> in the test bed, which was way better than the customer finding it.

Yes, but we don't really want alloc_skb() doing this, this makes the
failures go to other places (like TCP, netlink, whatever) instead of
what you're trying to actually test (RX out of buffer handling in
a specific driver).

It is an interesting thing to test too, no doubt.
