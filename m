From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Wed, 11 Feb 2004 21:15:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211211536.23e97997.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: qnex@atlantis.knm.org.pl, netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1076562282.1033.76.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Feb 2004 00:04:42 -0500
jamal <hadi@cyberus.ca> wrote:

> More complete patch attached for other broken tunnel devices.
> Note the bug exists in 2.4 as well but is masquareded by a boundary bug
> in pfifo.

OK, however, old behavior would be like setting tx_queue_len to '1'.
Do we wish to preserve this?
