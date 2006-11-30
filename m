From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting, purging
 etc.
Date: Thu, 30 Nov 2006 13:22:47 +0100
Message-ID: <456ECD17.2010202@trash.net>
References: <20061127065614.GB1625@ff.dom.local> <456AB61B.3040205@trash.net> <20061127104140.GA2866@ff.dom.local> <456AC07E.6000606@trash.net> <20061128063743.GA1797@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:18883 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936383AbWK3MWx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 07:22:53 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061128063743.GA1797@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> [NET_SCHED] sch_cbq:
> 
> [PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]
> 
> - P. McHardy's "Fix endless loops" patch supplement
>   (cbq_graft, cbq_qlen_notify, cbq_delete, cbq_class_ops)
> 
> - deactivating of active classes when q.qlen drops to zero
>   (cbq_drop)
> 
> - a redundant instruction removed from cbq_deactivate_class
> 
> PS: probably htb_deactivate in htb_delete and
> cbq_deactivate_class in cbq_delete are also
> redundant now.

This looks good, thanks.

