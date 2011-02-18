From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v6 0/9] net: Unified offload configuration
Date: Fri, 18 Feb 2011 15:22:38 +0100
Message-ID: <20110218142238.GA18099@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl> <20110217.145611.229745070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38875 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043Ab1BROWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 09:22:40 -0500
Content-Disposition: inline
In-Reply-To: <20110217.145611.229745070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 02:56:11PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Wed, 16 Feb 2011 03:59:16 +0100 (CET)
> > Here's a v6 of the ethtool unification patch series.
> >=20
> > What's in it?
> >  1..4:
> > 	cleanups for the core patches
> >  5:
> > 	the patch - implement unified ethtool setting ops
> >  6..7:
> > 	implement interoperation between old and new ethtool ops
> >  8:
> > 	include RX checksum in features and plug it into new framework
> >  9:
> > 	convert loopback device to new framework
> >=20
> > What is it good for?
> >  - unifies driver behaviour wrt hardware offloads
> >  - removes a lot of boilerplate code from drivers
> >  - allows better fine-grained control over used offloads
> Applied to net-next-2.6, please send any bug fixes relative to this.
>=20
> Please get rid of that annoying message spit out by netif_features_ch=
ange(),
> it's just spam.  If we want notifications for stuff like this, use a
> non-unicast netlink message so those who want to hear it can do so.

You mean netdev_update_features() "Features changed" message? Is it ok
to just demote it to DEBUG level or you want to remove it altogether?
What about netdev_fix_features() messages?

Best Regards,
Micha=B3 Miros=B3aw
