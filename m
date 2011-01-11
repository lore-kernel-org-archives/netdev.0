From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 00/10] net/fec: add dual fec support for i.MX28
Date: Tue, 11 Jan 2011 16:15:36 +0800
Message-ID: <20110111081535.GA2686@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <20110109.154409.242134862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <gerg@snapgear.com>, <baruch@tkos.co.il>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <r64343@freescale.com>,
	<B32542@freescale.com>, <u.kleine-koenig@pengutronix.de>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<jamie@jamieiles.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:39713
	"EHLO DB3EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753988Ab1AKIM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 03:12:58 -0500
Received: from mail107-db3 (localhost.localdomain [127.0.0.1])	by
 mail107-db3-R.bigfish.com (Postfix) with ESMTP id 73E801C6053C	for
 <netdev@vger.kernel.org>; Tue, 11 Jan 2011 08:12:56 +0000 (UTC)
Received: from DB3EHSMHS012.bigfish.com (unknown [10.3.81.246])	by
 mail107-db3.bigfish.com (Postfix) with ESMTP id 31B284B804E	for
 <netdev@vger.kernel.org>; Tue, 11 Jan 2011 08:12:56 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p0B8CqOG003642	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 01:12:52 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p0B8CpQi016778	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 02:12:51 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110109.154409.242134862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Sun, Jan 09, 2011 at 03:44:09PM -0800, David Miller wrote:
> From: Shawn Guo <shawn.guo@freescale.com>
> Date: Thu, 6 Jan 2011 15:13:08 +0800
> 
> > This patch series is to add dual fec support for mx28, which is
> > a mxs-based soc. Some code changes related to the following commits
> > are also made in this patch set for some reasons.
> > 
> >  e6b043d512fa8d9a3801bf5d72bfa3b8fc3b3cc8
> >  netdev/fec.c: add phylib supporting to enable carrier detection (v2)
> > 
> >  e3fe8558c7fc182972c3d947d88744482111f304
> >  net/fec: fix pm to survive to suspend/resume
> > 
> > It's been tested on mx28 evk and mx51 babbage. For mx28, it has
> > to work against the tree
> > 
> >  git://git.pengutronix.de/git/imx/linux-2.6.git imx-for-2.6.38
> > 
> > plus patch
> > 
> >  [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
> > 
> > The 3 patches below preceding with * have changes since v3, and
> > the detailed change log can be found in individual patch.
> 
> I've applied all of the "net/fec:" patches (#1 to #5) to net-2.6,
> please push the ARM changes via the appropriate ARM tree.
> 
Is there anything needs to be done to get the following patches
merged?

 [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
 [PATCH v4 00/10] net/fec: add dual fec support for i.MX28, #6 to #10.

-- 
Regards,
Shawn

