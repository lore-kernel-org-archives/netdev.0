From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 16:23:40 +0200
Message-ID: <20110516142340.GA2980@rere.qmqm.pl>
References: <20110516121339.GA1094@rere.qmqm.pl>
 <1305335142.2851.70.camel@bwh-desktop>
 <20110514103539.GA5214@rere.qmqm.pl>
 <1305513923.19966.20.camel@localhost>
 <20110516132807.1A89F13A6A@rere.qmqm.pl>
 <1305553066.19966.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39889 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525Ab1EPOXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 10:23:41 -0400
Content-Disposition: inline
In-Reply-To: <1305553066.19966.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 15:28 +0200, Micha=B3 Miros=B3aw wrote:
> > Remove NETIF_F_COMPAT since it's redundant and will be unused after
> > all drivers are converted to fix/set_features.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >=20
> > For net as we don't want to have ETHTOOL_F_COMPAT hit stable releas=
e.
> [...]
> ETHTOOL_F_WISH means that the requested features could not all be
> enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they were not
> remembered.

Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c556f9
(net: Implement SFEATURES compatibility for not updated drivers).

Best Regards,
Micha=B3 Miros=B3aw
