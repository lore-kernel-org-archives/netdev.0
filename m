From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Sat, 14 Feb 2004 12:49:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040214124958.499294a6.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
	<20040211211536.23e97997.davem@redhat.com>
	<1076563502.1031.85.camel@jzny.localdomain>
	<1076564638.1033.91.camel@jzny.localdomain>
	<20040211215142.7f817513.davem@redhat.com>
	<1076566176.1033.94.camel@jzny.localdomain>
	<20040211222259.776ad818.davem@redhat.com>
	<402D54D6.5070708@trash.net>
	<20040213213606.5a13cc76.davem@redhat.com>
	<1076762757.1060.4.camel@jzny.localdomain>
	<1076763997.1059.13.camel@jzny.localdomain>
	<1076766981.1059.16.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, qnex@atlantis.knm.org.pl, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1076766981.1059.16.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 14 Feb 2004 08:56:21 -0500
jamal <hadi@cyberus.ca> wrote:

> And the closest to a sane patch in 30 secs that compiles is attached
> to describe the idea.

I don't know how wise this tx_queue_len fiddling is.

With this, if user modifies tx_queue_len himself, on ifdown this configuration
change is lost if user sets it explicitly to '1'.  See?  In fact you could
call it corruption :-)

I think Alexey maybe meant something different, achieving the ends by some other
means than directly fiddling with tx_queue_len.
