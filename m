From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 14/16] Intel net drivers: convert to ndo_fix_features
Date: Thu, 7 Apr 2011 14:51:27 +0200
Message-ID: <20110407125127.GA16755@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <28a1c0f6e1ab9a523ee1e947ca4a013fd5730539.1295734271.git.mirq-linux@rere.qmqm.pl> <AANLkTikYg6x-T42eSh-ou=bJr=16wLxoVYXON5qiyyvu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59225 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab1DGMv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 08:51:28 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikYg6x-T42eSh-ou=bJr=16wLxoVYXON5qiyyvu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 26, 2011 at 01:47:46AM -0800, Jeff Kirsher wrote:
> 2011/1/22 Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>:
> > Private rx_csum flags are now duplicate of netdev->features & NETIF=
_F_RXCSUM.
> > Removing this needs deeper surgery.
> >
> > Since ixgbevf doesn't change hardware state on RX csum enable/disab=
le
> > its reset is avoided.
> >
> > Things noticed:
> > =A0- e1000, e1000e and ixgb have RX csum disabled by default
> > =A0- HW VLAN acceleration probably can be toggled, but it's left as=
 is
> > =A0- the resets on RX csum offload change can probably be avoided
> > =A0- there is A LOT of copy-and-pasted code here
[...]
> Upon initial reviews of the patch, we found issues with the e1000e
> changes so far.  We are working to put together a patch to resolve th=
e
> issues (and to do the conversion to ndo_fix_features).  Based on the
> initial work done by Michal, we can take care of the changes necessar=
y
> for the Intel Wired Ethernet drivers, and will wait for acceptance of
> the net and ethtool changes before pushing the Intel patch.  Is that
> acceptable?
>=20
> For e1000e, this patch breaks the ability to manually override the
> default behavior of disabling TSO for 10/100, and there is some
> additional cleanup that can be done w.r.t. Rx csum flags.

I resent other patches after the ethtool changes got it 2.6.39-rc, but =
skipped
this one based on your mail. Do you want me to resend parts not relevan=
t
to e1000e or can I drop it altogether from my queue?

Best Regards,
Micha=B3 Miros=B3aw
