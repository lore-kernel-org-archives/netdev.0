From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: probably bug in drr scheduler, 2.6.29-rc5
Date: Fri, 27 Feb 2009 02:46:13 -0800 (PST)
Message-ID: <20090227.024613.141114390.davem@davemloft.net>
References: <200902261745.28952.denys@visp.net.lb>
	<20090227101634.GD4156@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758768AbZB0Kqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 05:46:34 -0500
In-Reply-To: <20090227101634.GD4156@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Feb 2009 10:16:34 +0000

> pkt_sched: sch_drr: Fix oops in drr_change_class.
> 
> drr_change_class lacks a check for NULL of tca[TCA_OPTIONS], so oops
> is possible.
> 
> Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied and queued up for -stable, thanks Jarek!
