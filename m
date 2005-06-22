From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 13:43:48 -0700 (PDT)
Message-ID: <20050622.134348.23010554.davem@davemloft.net>
References: <20050622180654.GX14251@wotan.suse.de>
	<20050622.132241.21929037.davem@davemloft.net>
	<42B9CBA2.5050208@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, becker@scyld.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com
In-Reply-To: <42B9CBA2.5050208@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 22 Jun 2005 13:35:46 -0700

> > Everyone seems to have this absolute fetish about batching the RX
> > descriptor refilling work.  It's wrong, it should be done when you
> > pull a receive packet off the ring, for many reasons.  Off the top of
> > my head:
> > 
> > 1) Descriptors are refilled as soon as possible, decreasing
> >    the chance of the device hitting the end of the RX ring
> >    and thus unable to receive a packet.
> 
> IFF one pokes the NIC for each buffer right?

Or "every 5" or something like that.
