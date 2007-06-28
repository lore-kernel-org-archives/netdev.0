From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 09:50:36 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0391@orsmsx414.amr.corp.intel.com>
References: <4683E5DE.7000805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54074 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751781AbXF1Quo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:50:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4683E5DE.7000805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Its not error handling. You do:
> 
> err = register qdisc 1
> if (err)
> 	return err;
> err = register qdisc 2
> if (err)
> 	unregister qdisc 2
> return err
> 
> anyways, I already fixed that and cleaned up prio_classify 
> the way I suggested. Will send shortly.

Thanks for fixing; however, the current sch_prio doesn't unregister the
qdisc if register_qdisc() on prio fails, or does that happen implicitly
because the module will probably unload?

Thanks again Patrick,
-PJ
