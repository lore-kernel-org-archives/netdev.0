From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 17:26:44 +0200
Message-ID: <20110505152644.GA8459@rere.qmqm.pl>
References: <20110504181813.GA17547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	herbert@gondor.hengli.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48607 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067Ab1EEP0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 11:26:46 -0400
Content-Disposition: inline
In-Reply-To: <20110504181813.GA17547@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
> BTW, I just noticed that net-next spits out
> many of the following when I run any VMs:
[...]
> tap0: Features changed: 0x40004040 -> 0x401b4849

Before this message, userspace called ioctl(TIOCSETOFFLOAD)
turning offloads on.

> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Features changed: 0x401b4849 -> 0x40004040

And then it probably called ioctl(TIOCSETOFFLOAD) again, disabling them=
=2E

Best Regards,
Micha=B3 Miros=B3aw
