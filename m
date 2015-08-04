From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix initial runtime PM refcount
Date: Tue, 4 Aug 2015 16:35:55 +0200
Message-ID: <20150804143555.GQ9999@pengutronix.de>
References: <1438674216.2458.24.camel@pengutronix.de>
 <Pine.LNX.4.44L0.1508041019380.1577-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucas Stach <l.stach@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>,
	Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
	netdev@vger.kernel.org, linux-pm@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	patchwork-lst@pengutronix.de, kernel@pengutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53952 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbHDOgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 10:36:03 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1508041019380.1577-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Aug 04, 2015 at 10:20:55AM -0400, Alan Stern wrote:
> In that case, adding a call pm_runtime_get_noresume() is the right=20
> thing to do.
Is this an ack for Lucas' patch?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
