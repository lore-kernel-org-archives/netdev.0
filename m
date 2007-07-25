From: Patrick McHardy <kaber@trash.net>
Subject: Re: [FIX] NET: Fix sch_api and sch_prio to properly set and detect
 the	root qdisc
Date: Wed, 25 Jul 2007 02:35:50 +0200
Message-ID: <46A69AE6.9030009@trash.net>
References: <20070724223346.10658.80645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37118 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbXGYAgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 20:36:35 -0400
In-Reply-To: <20070724223346.10658.80645.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> This is a patch from Patrick McHardy to fix the sch_api code, which I
> went ahead and tested and made a slight fix to.  This also includes
> the fix to sch_prio based on Patrick's patch.
> 
> The sch->parent handle should contain the parent qdisc ID.  When the
> qdisc is the root qdisc (TC_H_ROOT), the parent handle should be the
> value TC_H_ROOT.  This fixes sch_api to set this correctly on
> qdisc_create() for both ingress and egress qdiscs.
> 
> Change this check in prio_tune() so that only the root qdisc can be
> multiqueue-enabled; use sch->parent instead of sch->handle.

Both look good, thanks.

Acked-by: Patrick McHardy <kaber@trash.net>
