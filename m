From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [NET_SCHED]: Fix prio/ingress classification logic error
Date: Thu, 26 Jul 2007 09:31:42 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034C0028@orsmsx414.amr.corp.intel.com>
References: <46A88643.5010003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linux Netdev List" <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36658 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757918AbXGZQbp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 12:31:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A88643.5010003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is the final fix for the problem Peter reported.
> Turns out most other schedulers get it right, the only other 
> case is ingress setting skb->tc_index to the uninitialized 
> value of res.classid.

I've applied this and tested prio and rr, and everything is happy again.
Thanks for finding this and putting the patch together.

I got lost in looking for the bug in the u32_classify() code, and missed
the easier defect...

Thanks again Patrick,
-PJ Waskiewicz
