From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/4] Ethtool: cleanup strategy
Date: Tue, 2 Nov 2010 01:14:23 +0000
Message-ID: <20101102011422.GM15074@solarflare.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <1288645525.2231.60.camel@achroite.uk.solarflarecom.com> <20101102010253.GC15848@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42499 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab0KBBO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 21:14:26 -0400
Content-Disposition: inline
In-Reply-To: <20101102010253.GC15848@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, Nov 01, 2010 at 09:05:25PM +0000, Ben Hutchings wrote:
[...]
> > It also might be worth defining a standard feature flag for RX chec=
ksum
> > offload, since currently every driver has to maintain its own priva=
te
> > flag.  Though we're running short of feature flags on 32-bit machin=
es.
>=20
> RX offloads are different in that most devices allow readback of
> configured bits, so actually no specific flags are needed.
[...]

Most devices also need resetting from time to time, so those flags stil=
l
need to be included in software state.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
