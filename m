From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 20:44:57 +0200
Message-ID: <467C18A9.5090802@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32903178F0B@orsmsx414.amr.corp.intel.com> <467C1800.2020103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36505 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759211AbXFVSpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 14:45:40 -0400
In-Reply-To: <467C1800.2020103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> void skb_set_queue_mapping(struct sk_buff *skb, unsigned int queue)
> {
> #ifdef CONFIG_NET_SCH_MULTIQUEUE
> 	skb->queue_mapping = queue;
> #else
> 	skb->queue_mapping = 0;
> #endif


Maybe even use it everywhere and guard skb->queue_mapping by
an #ifdef, on 32 bit it does enlarge the skb.

