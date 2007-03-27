From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 5/7] bonding: replace system timer with work queue
Date: Mon, 26 Mar 2007 21:56:48 -0800
Message-ID: <20070326215648.58cb392b.akpm@linux-foundation.org>
References: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, perex@suse.cz,
	ctindel@users.sourceforge.net, fubar@us.ibm.com, oleg@tv-sign.ru,
	shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40730 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934051AbXC0F5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:57:05 -0400
In-Reply-To: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Mar 2007 21:50:01 -0800 akpm@linux-foundation.org wrote:

> Replace system timer with work queue in monitor functions.  The reason for
> this change is that bonding handlers calls various sleeping functions from
> the timer handler which is not allowed.  Because we cannot share the main
> workqueue threads (rtnl_lock is used also in linkwatch_event) - new bond
> workqueue thread is created.

I have a note here that this patch needs additional work.

I forget what it was, there has since been no followup and hence I shall now
drop this patch.
