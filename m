From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add init_dummy_netdev() and fix EMAC driver using it
Date: Wed, 14 Jan 2009 21:05:14 -0800 (PST)
Message-ID: <20090114.210514.257703205.davem@davemloft.net>
References: <1231906495.22571.79.camel@pasglop>
	<Pine.LNX.4.64.0901141057110.31703@vixen.sonytel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Geert.Uytterhoeven@sonycom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52405
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756505AbZAOFFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:05:13 -0500
In-Reply-To: <Pine.LNX.4.64.0901141057110.31703@vixen.sonytel.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Date: Wed, 14 Jan 2009 11:00:05 +0100 (CET)

> On Wed, 14 Jan 2009, Benjamin Herrenschmidt wrote:
> > This adds an init_dummy_netdev() function that gets a network device
> > structure (allocation and lifetime entirely under caller's control) and
> > initialize the minimum amount of fields so it can be used to schedule
> > NAPI polls without registering a full blown interface. This is to be
> > used by drivers that need to tie several hardware interfaces to a single
> > NAPI poll scheduler due to HW limitations.
> > 
> > It also updates the ibm_newemac driver to use that, this fixing the
> > oops on 2.6.29 due to passing NULL as "dev" to netif_napi_add()
> > 
> > Symbol is exported GPL only a I don't think we want binary drivers doing
> > that sort of acrobatics (if we want them at all).
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> Thanks, this fixed my Sequoia!
> 
> Tested-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

Applied, thanks everyone.
