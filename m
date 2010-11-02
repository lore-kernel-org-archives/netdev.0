From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 0/4] Ethtool: cleanup strategy
Date: Tue, 2 Nov 2010 02:30:32 +0100
Message-ID: <20101102013032.GF15848@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <1288645525.2231.60.camel@achroite.uk.solarflarecom.com> <20101102010253.GC15848@rere.qmqm.pl> <20101102011422.GM15074@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45740 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab0KBBad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 21:30:33 -0400
Content-Disposition: inline
In-Reply-To: <20101102011422.GM15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 01:14:23AM +0000, Ben Hutchings wrote:
> Micha=B3 Miros=B3aw wrote:
> > On Mon, Nov 01, 2010 at 09:05:25PM +0000, Ben Hutchings wrote:
> [...]
> > > It also might be worth defining a standard feature flag for RX ch=
ecksum
> > > offload, since currently every driver has to maintain its own pri=
vate
> > > flag.  Though we're running short of feature flags on 32-bit mach=
ines.
> > RX offloads are different in that most devices allow readback of
> > configured bits, so actually no specific flags are needed.
> [...]
> Most devices also need resetting from time to time, so those flags st=
ill
> need to be included in software state.

Ah. Good point. So this should be converted to the same way the TX offl=
oads
will be handled.

Is it worth to split rx and tx features to separate bitfields?  Especia=
lly
that we're running out of bits in u32 and that TX flags are used in hot
path and RX are normally not accessed much.

Are the features flags exported somewhere to userspace except via ethto=
ol?

Best Regards,
Micha=B3 Miros=B3aw
