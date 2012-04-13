From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] New CAIF features
Date: Fri, 13 Apr 2012 11:37:57 -0400 (EDT)
Message-ID: <20120413.113757.896106674970820826.davem@davemloft.net>
References: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500Ab2DMPiH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 11:38:07 -0400
In-Reply-To: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Thu, 12 Apr 2012 20:27:23 +0200

> Add feature to aggregate CAIF HSI frames into one large HSI-transfer.
> The triggers for starting a HSI transfer are:
> Max transfer size reached, timeout or reception of low-latency traffi=
c.=20
> As long as none of these triggers are met, CAIF-frames will be aggreg=
ated.
> =20
> In order to be able to support aggregation and detect low-latency tra=
ffic,
> CAIF packets are assigned a TC class.
> =20
> In addition we are now allowing other kernel modules to use the HSI i=
nterface
> while the CAIF interface is closed. The CAIF-HSI interface is changed=
 so that
> reference to the HSI interface is held only when CAIF-HSI is in state=
 UP.
> Initialization/de-initialization of the HSI HW is performed when the =
interface
> is opened/closed instead of at module load time.
>=20
> NOTE: This patch-set depends on the patch "caif-hsi: Free flip_buffer=
 at shutdown",
> sent in the Bug-fix patch-set.

All applied, thanks for letting me know explicitly about the dependency=
=2E
