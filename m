From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 1/7] netdev: add standardized irq naming function
Date: Tue, 21 Jun 2011 10:56:18 -0700
Message-ID: <20110621105618.358347a8@nehalam.ftrdhcpuser.net>
References: <20110621170541.309890798@vyatta.com>
	<20110621170658.395370414@vyatta.com>
	<BANLkTi=b89+C=-fnJuacKTKZXBYYouNK=w@mail.gmail.com>
	<1308678535.2743.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39260 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757082Ab1FUR4U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 13:56:20 -0400
In-Reply-To: <1308678535.2743.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 18:48:55 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2011-06-21 at 19:30 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > 2011/6/21 Stephen Hemminger <shemminger@vyatta.com>:
> > > To force driver developers to use a standard convention for namin=
g
> > > network device IRQ's, provide a standardized method for creating
> > > the name.
> >=20
> > Can this be modified to track netdev renames?
>=20
> We should handle renames somehow.
>=20
> sfc currently uses a netdev notifier to update the names of its IRQs
> (and MTDs) but it might make more sense to add something to
> net_device_ops rather than having every driver receive notification f=
or
> every device.
>=20
> Ben.
>=20

Since renames are only allowed when netdevice is down.
Renames do not need to be tracked if device registers irq in open
handler.
