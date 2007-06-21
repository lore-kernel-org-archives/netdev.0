From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 13:15:05 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903146E12@orsmsx414.amr.corp.intel.com>
References: <467ACD41.4020605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19170 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbXFUUPJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 16:15:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467ACD41.4020605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Yes.  This is the tc command I used to configure the qdisc (with 
> > q_rr.c attached from my patches iproute2 package):
> >
> > # tc qdisc add dev eth2 root handle 1: rr bands 8 RTNETLINK 
> answers: 
> > No such file or directory
> 
> Again, I bet you don't have CONFIG_NET_SCH_RR enabled:

Chalk this up to serious user error.  Having CONFIG_NET_SCH_RR=m isn't
defining it...I'm not sure why I thought that was correct.  Thanks for
bearing with me Patrick.  Working as intended now.  :-)

-PJ
