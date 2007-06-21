From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 10:55:12 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903146C4B@orsmsx414.amr.corp.intel.com>
References: <4676F111.4000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46444 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755523AbXFURz2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 13:55:28 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4676F111.4000105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> BTw, couldn't you just merge sch_rr with prio? AFAICT you 
> only need a new dequeue function, a new struct Qdisc_ops and 
> a MODULE_ALIAS.

Ok, I have this somewhat working, but need to poll for some help from
the community.  I used MODULE_ALIAS("sch_rr") in sch_prio.c, and
modprobe is happily loading sch_prio.ko when I ask for sch_rr.ko.  It
also recognizes the correct ops struct to associate with the instance of
the module.  However, when I try to load the qdisc via tc (modified
version that knows sch_rr), I'm getting No Such File or Directory from
RTNETLINK.  It's looking for sch_rr.ko, and is bailing.  I've scoured
the code looking for a reason why, and am drawing a blank.  I'll
continue looking, but if this sounds familiar to someone who knows how
to get around this, please reply and let me know.

Thanks,

-PJ Waskiewicz
