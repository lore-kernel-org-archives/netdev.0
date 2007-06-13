From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 11:22:30 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290306A83B@orsmsx414.amr.corp.intel.com>
References: <20070613.112017.130846513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Robert.Olsson@data.slu.se>, "Zhu, Yi" <yi.zhu@intel.com>,
	<Leonid.Grossman@neterion.com>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61052 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406AbXFMSWf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:22:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070613.112017.130846513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: jamal <hadi@cyberus.ca>
> Date: Wed, 13 Jun 2007 09:33:22 -0400
> 
> > So in such a case (assuming 8 rings), One model is creating 
> 4 netdev 
> > devices each based on single tx/rx ring and register set and then 
> > having a mother netdev (what you call the bond) that feeds these 
> > children netdev based on some qos parametrization is very sensible.
> 
> Why all of this layering and overhead for something so BLOODY 
> SIMPLE?!?!?
> 

I am currently packing up the newest patches against 2.6.23, with
feedback from Patrick.  The delay in posting them was a weird panic with
the loopback device, which I just found.  Let me run a test cycle or
two, and I'll send them today for review, including an e1000 patch to
show how to use the API.

Cheers,
-PJ Waskiewicz
