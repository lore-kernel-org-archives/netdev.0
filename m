From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: 12 Feb 2004 00:25:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076563502.1031.85.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	 <20040211200549.736fa8b3.davem@redhat.com>
	 <1076561489.1032.65.camel@jzny.localdomain>
	 <1076561998.1035.72.camel@jzny.localdomain>
	 <1076562282.1033.76.camel@jzny.localdomain>
	 <20040211211536.23e97997.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: qnex@atlantis.knm.org.pl, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040211211536.23e97997.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-02-12 at 00:15, David S. Miller wrote:
> On 12 Feb 2004 00:04:42 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > More complete patch attached for other broken tunnel devices.
> > Note the bug exists in 2.4 as well but is masquareded by a boundary bug
> > in pfifo.
> 
> OK, however, old behavior would be like setting tx_queue_len to '1'.
> Do we wish to preserve this?

All the alloc_netdev() types of calls dont set this - so default is
zero. Maybe we could move it there. 100 seems to be what a lot of
10/100 ether devices set things to be.
Note that ifconfig and ip can set this value as well at runtime

cheers,
jamal
