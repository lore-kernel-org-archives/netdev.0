From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] skge: convert to hw_features
Date: Thu, 31 Mar 2011 22:48:03 +0200
Message-ID: <20110331204803.GA28109@rere.qmqm.pl>
References: <20110331110135.9625513A68@rere.qmqm.pl> <20110331084102.71eb2b55@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38197 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1CaUsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 16:48:08 -0400
Content-Disposition: inline
In-Reply-To: <20110331084102.71eb2b55@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 31, 2011 at 08:41:02AM -0700, Stephen Hemminger wrote:
> On Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > >From the code it looks like the hardware might support full HW_CSU=
M not
> > just IP_CSUM.  This needs testing and so is not changed here.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> I don't think this will work right. The old code did not allow settin=
g
> tx/rx csum on the older GENESIS chip,=20

If you look at the changes near the end of patche, the hw_features are =
set
(and so features are made changeable) only when hw->chip_id !=3D CHIP_I=
D_GENESIS.

Best Regards,
Micha=B3 Miros=B3aw
