From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 1/7] netdev: add standardized irq naming function
Date: Tue, 21 Jun 2011 18:48:55 +0100
Message-ID: <1308678535.2743.27.camel@bwh-desktop>
References: <20110621170541.309890798@vyatta.com>
	 <20110621170658.395370414@vyatta.com>
	 <BANLkTi=b89+C=-fnJuacKTKZXBYYouNK=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6513 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756950Ab1FURs7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 13:48:59 -0400
In-Reply-To: <BANLkTi=b89+C=-fnJuacKTKZXBYYouNK=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 19:30 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/6/21 Stephen Hemminger <shemminger@vyatta.com>:
> > To force driver developers to use a standard convention for naming
> > network device IRQ's, provide a standardized method for creating
> > the name.
>=20
> Can this be modified to track netdev renames?

We should handle renames somehow.

sfc currently uses a netdev notifier to update the names of its IRQs
(and MTDs) but it might make more sense to add something to
net_device_ops rather than having every driver receive notification for
every device.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

