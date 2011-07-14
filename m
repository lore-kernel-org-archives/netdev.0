From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 09/10] net: remove /sys/class/net/*/features
Date: Thu, 14 Jul 2011 22:46:03 +0200
Message-ID: <20110714204603.GB16759@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
 <ce3c2d463fa75fe00052658cf29e73375f965ab7.1310601401.git.mirq-linux@rere.qmqm.pl>
 <20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58580 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab1GNUqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 16:46:05 -0400
Content-Disposition: inline
In-Reply-To: <20110713175037.7cbf772a@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2011 at 05:50:37PM -0700, Stephen Hemminger wrote:
> On Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
>=20
> > The same information and more can be obtained by using ethtool
> > with ETHTOOL_GFEATURES.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Changing user visible API has to go through a longer process
> such as putting it in feature-removal-schedule.txt for a while
> (at couple of releases) before removing.

Well, it's broken and prevents improving then features infrastructure.
Besides, it was never documented and meaing of bits it returns is
already kernel version dependent.

Best Regards,
Micha=B3 Miros=B3aw
