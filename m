From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 10:00:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317100001.7d33accc@dell_ss3.pdx.osdl.net>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
	<1079539766.1034.99.camel@jzny.localdomain>
	<20040317095107.60728e4e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040317095107.60728e4e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Mar 2004 09:51:07 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On 17 Mar 2004 11:09:26 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > A simple algorithm is random().
> 
> Yes, but you want to weight it just a bit.  Userland could use random()
> to generate the bit-stream in fact :)


In an earlier project we had a test suite that failed the Nth allocation,
then repeated startup failing from 1 till all allocations in a typical
interaction round trip had been tested.  Sure led to some nasty failures
in the test bed, which was way better than the customer finding it.

-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
