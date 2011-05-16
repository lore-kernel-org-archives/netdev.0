From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 10:28:46 +0300
Message-ID: <20110516072846.GA6610@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110505152644.GA8459@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	herbert@gondor.hengli.com.au
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35742 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806Ab1EPH2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 03:28:44 -0400
Content-Disposition: inline
In-Reply-To: <20110505152644.GA8459@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 05:26:44PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
> > BTW, I just noticed that net-next spits out
> > many of the following when I run any VMs:
> [...]
> > tap0: Features changed: 0x40004040 -> 0x401b4849
>=20
> Before this message, userspace called ioctl(TIOCSETOFFLOAD)
> turning offloads on.
>=20
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Features changed: 0x401b4849 -> 0x40004040
>=20
> And then it probably called ioctl(TIOCSETOFFLOAD) again, disabling th=
em.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw


I'd have to look at this some more, but I know qemu-kvm
supports offloads with current kernels.
There seems to be some kernel behaviour change here.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
