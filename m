From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 11:20:17 -0700 (PDT)
Message-ID: <20070613.112017.130846513.davem@davemloft.net>
References: <1181737935.4050.87.camel@localhost>
	<18031.60741.695897.572432@robur.slu.se>
	<1181741602.4050.116.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, yi.zhu@intel.com,
	Leonid.Grossman@neterion.com, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758790AbXFMSUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:20:03 -0400
In-Reply-To: <1181741602.4050.116.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 13 Jun 2007 09:33:22 -0400

> So in such a case (assuming 8 rings), One model is creating 4 netdev
> devices each based on single tx/rx ring and register set and then
> having a mother netdev (what you call the bond) that feeds these
> children netdev based on some qos parametrization is very sensible.

Why all of this layering and overhead for something so
BLOODY SIMPLE?!?!?

