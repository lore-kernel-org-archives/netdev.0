From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/2] netxen: support for GbE port settings
Date: Mon, 14 Mar 2011 15:54:20 -0700 (PDT)
Message-ID: <20110314.155420.57460529.davem@davemloft.net>
References: <1300141822.2584.71.camel@bwh-desktop>
	<20110314.153240.241445951.davem@davemloft.net>
	<1300142648.2584.76.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com,
	sony.chacko@qlogic.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715Ab1CNWxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:53:42 -0400
In-Reply-To: <1300142648.2584.76.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Mar 2011 22:44:08 +0000

> For link settings, that isn't clear, and drivers should simply
> reject invalid combinations.

Ok, makes sense.

Amit please update your patch to silently reject link setting attempts
that are unsupported by the device.

Thanks.
