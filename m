From: David Miller <davem@davemloft.net>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
 driver to request_firmware()
Date: Mon, 30 Jun 2008 12:46:41 -0700 (PDT)
Message-ID: <20080630.124641.13641106.davem@davemloft.net>
References: <1214837678.10393.345.camel@pmac.infradead.org>
	<200806301610.m5UGAlqr025302@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751650AbYF3Tql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:46:41 -0400
In-Reply-To: <200806301610.m5UGAlqr025302@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Mon, 30 Jun 2008 12:10:47 -0400

> In message <1214837678.10393.345.camel@pmac.infradead.org>,David Woodhouse writ
> es:
> >> i removed the #ifdef's from around MODULE_LICENSE().  there shouldnt
> >> be any need for #ifdef's around MODULE_FIRMWARE() either.
> >
> >Unless you put #ifdef CONFIG_SBUS around the
> >MODULE_FIRMWARE("sba200e_ecd.bin") you will be requesting that firmware
> >even on non-sbus machines. Likewise little-endian vs. big-endian on PCI.
> 
> does it?  i was under the impression that MODULE_FIRMWARE() just
> provides a hint that modinfo can read.  request_firmware() still
> the requestor for the firmware image.

And also, there are systems with both PCI and SBUS so we should
make sure we handle that properly here.
