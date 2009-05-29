From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin
 EMAC interrupt may not be shared
Date: Fri, 29 May 2009 04:28:17 -0700 (PDT)
Message-ID: <20090529.042817.176293351.davem@davemloft.net>
References: <8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
	<20090529.041435.163819214.davem@davemloft.net>
	<8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756561AbZE2L2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:28:17 -0400
In-Reply-To: <8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 07:22:05 -0400

> why implement extra over head in an interrupt handler to support an
> operating mode the hardware can never support.

What overhead?  It should be pretty easy to see if the device
is really indicating an interrupt or not :-)

