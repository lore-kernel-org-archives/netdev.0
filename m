From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 07/10] net: remove NETIF_F_NO_CSUM feature
Date: Thu, 14 Jul 2011 22:56:23 +0200
Message-ID: <20110714205623.GD16759@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
 <aa24cb5cdd3bd082d038960efd7d5c9a2ba95d8e.1310601401.git.mirq-linux@rere.qmqm.pl>
 <1310603009.2756.8.camel@bwh-desktop>
 <CA+mtBx9GXf_+DGB4EabS74Hf+16KKJ78Ty_zK6Y3tC+X634jtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60155 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456Ab1GNU4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 16:56:25 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx9GXf_+DGB4EabS74Hf+16KKJ78Ty_zK6Y3tC+X634jtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2011 at 05:30:37PM -0700, Tom Herbert wrote:
> On Wed, Jul 13, 2011 at 5:23 PM, Ben Hutchings <bhutchings@solarflare=
=2Ecom>wrote:
> > On Thu, 2011-07-14 at 02:10 +0200, Micha=B3 Miros=B3aw wrote:
> > > There are no explicit users, so this is now equivalent to
> > NETIF_F_HW_CSUM.
> > [...]
> > I think this is still a useful distinction, even the networking cor=
e
> > currently doesn't care about the difference.
> Agreed.  It seems like this is the only way to distinguish virtual de=
vices
> from HW devices (like we did with nocachecopy check).

You can't reliably detect virtual devices by this method. No tunnel dev=
ices
use this flag and it also doesn't detect e.g. IPsec being used on the r=
oute
(and no-cache copy should be disabled at least for software encryption)=
=2E

That's why its turned off by default and should be enabled only when us=
er
knows he will win some pps with it.

Best Regards,
Micha=B3 Miros=B3aw
