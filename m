From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] iproute2: sch_rr support in tc
Date: Thu, 28 Jun 2007 09:47:45 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0383@orsmsx414.amr.corp.intel.com>
References: <4683E485.8050907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@linux-foundation.org>, <netdev@vger.kernel.org>,
	<jeff@garzik.org>, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59284 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756463AbXF1Qrs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:47:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4683E485.8050907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Since rr is not built as a module you could actually put 
> everything in q_prio and share the code. But I don't really care :)

I tried doing this, but I couldn't get things working quite right with
selecting the correct module from sch_prio to sch_rr.  So I just added
the q_rr.c portion of tc, and it fixed the selection issues I was
seeing.  At least for userspace, it may be better to explicitly show the
existance of rr being independent; that's just my personal preference.

Cheers,
-PJ
