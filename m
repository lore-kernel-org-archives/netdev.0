From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC v2 2/2] e100: Support RXFCS feature flag.
Date: Tue, 12 Jul 2011 17:23:36 +0100
Message-ID: <1310487816.2732.13.camel@bwh-desktop>
References: <1308942371-12748-1-git-send-email-greearb@candelatech.com>
	 <1308942371-12748-3-git-send-email-greearb@candelatech.com>
	 <BANLkTiknCV1HknVpEdK97yU8eJwaJ5Y5Ag@mail.gmail.com>
	 <4E0B3510.2080202@candelatech.com>
	 <BANLkTikaJNa2+jbW6HWwc+tEE-ciNxvkLg@mail.gmail.com>
	 <4E0B383E.8020807@candelatech.com>
	 <BANLkTi=-ibpBiWBZ=AANybmWMWfMVGfe4Q@mail.gmail.com>
	 <4E0B42CE.30400@candelatech.com>
	 <CAHXqBFL-QgKvrvcrjtjSgDdeH9i7Ai86U2ujQ4xpo-vXLEkO5A@mail.gmail.com>
	 <20110712090000.29c17c20@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3352 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854Ab1GLQXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 12:23:39 -0400
In-Reply-To: <20110712090000.29c17c20@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-12 at 09:00 -0700, Stephen Hemminger wrote:
> On Tue, 12 Jul 2011 17:49:49 +0200
> Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:
>=20
> > wanted_features only reflects what is requested by user, this
> > combination might be invalid. When conditions change this value
> > combined with other bits in features are passed through
> > ndo_fix_features callback and netdev_fix_features() to bring it to
> > valid state, and then (if resulting set is different than current
> > features) ndo_set_features() is called to reconfigure device for th=
at
> > new state change to it.
>=20
> Since this semantic is more complicated than most other parts
> of network device interface API; could you please put a detailed
> documentation into Documentation/networking/netdevices.txt
>=20
> The whole netdevices.txt document could use some extending and
> rewriting as well.

Given that it has missed the last 3 years of API changes (and many
before that) I think it would be better to convert it into kernel-doc
comments in netdevice.h.  That would make it more obvious to driver
authors trying to understand the API, and to those changing the driver
API.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

