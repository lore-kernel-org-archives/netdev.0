From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: 12 Feb 2004 00:43:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076564638.1033.91.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	 <20040211200549.736fa8b3.davem@redhat.com>
	 <1076561489.1032.65.camel@jzny.localdomain>
	 <1076561998.1035.72.camel@jzny.localdomain>
	 <1076562282.1033.76.camel@jzny.localdomain>
	 <20040211211536.23e97997.davem@redhat.com>
	 <1076563502.1031.85.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: qnex@atlantis.knm.org.pl, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1076563502.1031.85.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-02-12 at 00:25, jamal wrote:

> > OK, however, old behavior would be like setting tx_queue_len to '1'.
> > Do we wish to preserve this?

I think i misunderstood you - you are saying maybe it was not a bug
after all in pfifo, right? i.e the off by one is ok.
I suppose you could look at it that way; i am just baffled that
tunnels worked fine though with that size of default.
Note the poster didnt seem to change the tx_queue_len 

cheers,
jamal
