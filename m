From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 17:30:08 -0400
Message-ID: <1181770208.4065.40.camel@localhost>
References: <1181737935.4050.87.camel@localhost>
	 <18031.60741.695897.572432@robur.slu.se>
	 <1181741602.4050.116.camel@localhost>
	 <20070613.112017.130846513.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, yi.zhu@intel.com,
	Leonid.Grossman@neterion.com, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:22065 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbXFMVaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 17:30:12 -0400
Received: by py-out-1112.google.com with SMTP id a29so592309pyi
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 14:30:11 -0700 (PDT)
In-Reply-To: <20070613.112017.130846513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-13-06 at 11:20 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Wed, 13 Jun 2007 09:33:22 -0400
> 
> > So in such a case (assuming 8 rings), One model is creating 4 netdev
> > devices each based on single tx/rx ring and register set and then
> > having a mother netdev (what you call the bond) that feeds these
> > children netdev based on some qos parametrization is very sensible.
> 
> Why all of this layering and overhead for something so
> BLOODY SIMPLE?!?!?

Are we still talking about the same thing?;->
This was about NICs which have multi register sets, tx/rx rings;
the only shared resource is the bus and the wire.
The e1000 cant do that. The thread is too long, so you may be talking
about the same thing.

cheers,
jamal

