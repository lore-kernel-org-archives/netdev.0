From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Thu, 28 Jun 2007 21:03:10 +0200
Message-ID: <468405EE.8070802@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0600@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57408 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759668AbXF1TEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:04:10 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031F0600@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Quick question: where are the sch_generic changes? :)
>>
>>If you hold for ten minutes I'll post a set of slightly 
>>changed patches with the NETDEVICES_MULTIQUEUE option and a 
>>fix for this.
> 
> 
> Jamal's and KK's qdisc_restart() rewrite took the netif_queue_stopped()
> call out of sch_generic.c.  So the underlying qdisc is only responsible
> for checking the queue status now before dequeueing.


Yes, I noticed that now. Doesn't seem right though as long as
queueing while queue is stopped is treated as a bug by the
drivers.

But I vaguely recall seeing a discussion about this, I'll check
the archives.
