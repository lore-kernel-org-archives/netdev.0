From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Thu, 23 Sep 2004 15:18:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923.151849.54646117.yoshfuji@linux-ipv6.org>
References: <414FC92F.6090009@tomt.net>
	<1095854932.17821.1190.camel@hades.cambridge.redhat.com>
	<20040922111544.469dc4c2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, andre@tomt.net, jgarzik@pobox.com, pp@ee.oulu.fi,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040922111544.469dc4c2.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040922111544.469dc4c2.davem@davemloft.net> (at Wed, 22 Sep 2004 11:15:44 -0700), "David S. Miller" <davem@davemloft.net> says:

> > It's not just tunnel interfaces. It seems to be related to hot-unplug of
> > interfaces with live IPv6 addresses. I've seen it on my prism54 card too
> > on many recent kernels. All I have to do is insert it and remove it a
> > few times. 
> 
> There is code in ipv6 which takes route references to devices and moves
> that reference over to loopback.  There might be bugs in that area, and
> I would suggest debugging in that area.

Okay, I'll look into it again...

--yoshfuji
