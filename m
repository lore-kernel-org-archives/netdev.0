From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Mon, 11 Apr 2011 02:51:00 +0200
Message-ID: <20110411005100.GA22103@rere.qmqm.pl>
References: <20110410131321.8CD9713A64@rere.qmqm.pl> <20110410115302.450794c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40198 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165Ab1DKAvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 20:51:03 -0400
Content-Disposition: inline
In-Reply-To: <20110410115302.450794c7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 10, 2011 at 11:53:02AM -0700, Stephen Hemminger wrote:
> On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > Caveats:
> >  - driver modifies vlan_features on HW VLAN TX changes
> >  - broken RX checksum will be reenabled on features change
> To be more precise. This is acceptable if and only if all cases
> where features are disabled in response to MTU and chip versions
> are exactly the same. We don't want to let some user stumble upon
> cases where hardware features don't work in their configuration.

I was referring to the unlikely case detected by sky2_rx_checksum().
Before this conversion, user could reenable the feature using ethtool.
The change is that now, in this case, it's reenabled also when other
features are changed (i.e. whenever netdev_update_features() gets calle=
d).

Best Regards,
Micha=B3 Miros=B3aw
