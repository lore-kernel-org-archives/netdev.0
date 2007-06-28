From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Thu, 28 Jun 2007 12:00:19 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0600@orsmsx414.amr.corp.intel.com>
References: <4683E92B.7000600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35772 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761249AbXF1TAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:00:22 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4683E92B.7000600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> >  include/linux/etherdevice.h |    3 +-
> >  include/linux/netdevice.h   |   62 
> ++++++++++++++++++++++++++++++++++++++++++-
> >  include/linux/skbuff.h      |    4 ++-
> >  net/core/dev.c              |   27 +++++++++++++------
> >  net/core/netpoll.c          |    8 +++---
> >  net/core/pktgen.c           |   10 +++++--
> >  net/core/skbuff.c           |    3 ++
> >  net/ethernet/eth.c          |    9 +++---
> >  8 files changed, 104 insertions(+), 22 deletions(-)
> 
> > include/linux/pkt_sched.h |    9 +++
> > net/sched/Kconfig         |   23 +++++++
> > net/sched/sch_prio.c      |  147
> +++++++++++++++++++++++++++++++++++++++++----
> >  3 files changed, 166 insertions(+), 13 deletions(-)
> 
> 
> Quick question: where are the sch_generic changes? :)
> 
> If you hold for ten minutes I'll post a set of slightly 
> changed patches with the NETDEVICES_MULTIQUEUE option and a 
> fix for this.

Jamal's and KK's qdisc_restart() rewrite took the netif_queue_stopped()
call out of sch_generic.c.  So the underlying qdisc is only responsible
for checking the queue status now before dequeueing.

-PJ
