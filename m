From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_cbq: deactivating when grafting,
 purging etc.
Date: Fri, 08 Dec 2006 00:27:11 -0800 (PST)
Message-ID: <20061208.002711.102122978.davem@davemloft.net>
References: <456AC07E.6000606@trash.net>
	<20061128063743.GA1797@ff.dom.local>
	<456ECD17.2010202@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425162AbWLHI05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 03:26:57 -0500
To: kaber@trash.net
In-Reply-To: <456ECD17.2010202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 30 Nov 2006 13:22:47 +0100

> Jarek Poplawski wrote:
> > [NET_SCHED] sch_cbq:
> > 
> > [PATCH 2.6.19-rc6 with "Fix endless loops" set of patches]
> > 
> > - P. McHardy's "Fix endless loops" patch supplement
> >   (cbq_graft, cbq_qlen_notify, cbq_delete, cbq_class_ops)
> > 
> > - deactivating of active classes when q.qlen drops to zero
> >   (cbq_drop)
> > 
> > - a redundant instruction removed from cbq_deactivate_class
> > 
> > PS: probably htb_deactivate in htb_delete and
> > cbq_deactivate_class in cbq_delete are also
> > redundant now.
> 
> This looks good, thanks.

Applied, thanks everyone.
