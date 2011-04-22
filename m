From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: allow user to change NETIF_F_HIGHDMA
Date: Fri, 22 Apr 2011 18:48:03 +0200
Message-ID: <20110422164803.GA24417@rere.qmqm.pl>
References: <20110422163116.37DE613909@rere.qmqm.pl> <20110422093850.13df40ce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45014 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756256Ab1DVQsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 12:48:04 -0400
Content-Disposition: inline
In-Reply-To: <20110422093850.13df40ce@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2011 at 09:38:50AM -0700, Stephen Hemminger wrote:
> On Fri, 22 Apr 2011 18:31:16 +0200 (CEST)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > NETIF_F_HIGHDMA is like any other TX offloads, so allow user to tog=
gle it.
> > This is needed later for bridge and bonding convertsion to hw_featu=
res.
> This was meant to be a hidden flag that that reflects capability of
> hardware. Do yo really mean to allow user to disable it via ethtool?

Yes. BTW, you can say the same about e.g. NETIF_F_SG. There's no harm i=
n
user being able to disable HIGHDMA (except obvious performance issue wh=
en
disabled -- as with other TX offloads).

Best Regards,
Micha=B3 Miros=B3aw
