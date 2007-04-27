From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 27 Apr 2007 08:46:36 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902BCE1E6@orsmsx414.amr.corp.intel.com>
References: <46321A33.8050103@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, "cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: "Jeff Garzik" <jgarzik@pobox.com>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36634 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756017AbXD0Pqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 11:46:47 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46321A33.8050103@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> jamal wrote:
> > Heres the way i see it from a user perspective:
> > If a NIC has 3 hardware queues; if that NIC supports strict 
> priority 
> > (i.e the prio qdisc) which we already support, there should 
> be no need 
> > for the user to really explicitly enable that support.
> > It should be transparent to them - because by configuring a multi 
> > queue prio qdisc (3 bands/queues default), they are already 
> doing multiqueues.
> 
> Agreed.
> 
> 	Jeff
>

Then for clarification, are you asking that I remove the "multiqueue"
option to TC and sch_prio, and have it behave the way it did a few
patches ago?

Thanks,

-PJ
