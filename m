From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Thu, 28 Jun 2007 15:32:40 -0400
Message-ID: <46840CD8.7000308@garzik.org>
References: <D5C1322C3E673F459512FB59E0DDC329031F061E@orsmsx414.amr.corp.intel.com> <468409E4.7000603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51633 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756516AbXF1Tcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 15:32:46 -0400
In-Reply-To: <468409E4.7000603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Yes, but there are users that don't go through qdiscs, like netpoll,
> Having them check the QDISC_RUNNING bit seems ugly.

Is netpoll the only such user?

netpoll tends to be a special case in every sense of the word, and I 
wish it was less so :/

	Jeff


