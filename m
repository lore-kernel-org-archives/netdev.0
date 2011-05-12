From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH] net: fold dev_disable_lro() into
 netdev_fix_features()
Date: Thu, 12 May 2011 18:06:21 +0200
Message-ID: <20110512160621.GA6588@rere.qmqm.pl>
References: <20110507114803.0D80A13A6B@rere.qmqm.pl>
 <20110509.120811.246541047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, bhutchings@solarflare.com,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49442 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757308Ab1ELQGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:06:25 -0400
Content-Disposition: inline
In-Reply-To: <20110509.120811.246541047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 09, 2011 at 12:08:11PM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Sat,  7 May 2011 13:48:02 +0200 (CEST)
> > This moves checks that device is forwarding from bridge, IPv4 and I=
Pv6
> > code into netdev_fix_features(). As a side effect, after device is =
no longer
> > forwarding it gets LRO back. This also means that user is not allow=
ed to
> > enable LRO after device is put to forwarding mode.
> We need to keep the check in the protocols because we don't want to
> be testing protocol specific device state in generic code like
> net/core/dev.c

I modified it to use priv_flags that mirror the protocol-internal state=
=2E
Patch follows.

Best Regards,
Micha=B3 Miros=B3aw
