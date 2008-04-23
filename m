From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Wed, 23 Apr 2008 15:49:53 -0700 (PDT)
Message-ID: <20080423.154953.161012169.davem@davemloft.net>
References: <480E4FA1.5020508@garzik.org>
	<20080422.150559.115368150.davem@davemloft.net>
	<m34p9smrmp.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751564AbYDWWtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 18:49:51 -0400
In-Reply-To: <m34p9smrmp.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Wed, 23 Apr 2008 19:02:22 +0200

> netdev_priv() was introduced at some point in time to allow
> alloc_netdev() to optionally allocate additional memory for internal
> use by the driver. It had nothing to do with dev->priv except "priv"
> name. The drivers don't use it passing size 0.

No, it was added as an optimization since the private
area was allocated together with the struct netdev, and
thus at a constant offset computable a compile time.

It was never meant to provide a facility to have two private areas
associated with a device, but unfortunately some broken stuff decided
to use it that way.
