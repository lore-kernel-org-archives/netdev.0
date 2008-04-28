From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: prevent unnecessary reordering
Date: Mon, 28 Apr 2008 02:03:56 -0700 (PDT)
Message-ID: <20080428.020356.105209144.davem@davemloft.net>
References: <20080427142216.GB7480@ami.dom.local>
	<20080428090453.GA4936@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765721AbYD1JD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 05:03:56 -0400
In-Reply-To: <20080428090453.GA4936@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 28 Apr 2008 09:04:53 +0000

> On 27-04-2008 16:22, Jarek Poplawski wrote:
> > [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
> > 
> 
> David, as Patrick noticed this patch was wrong and I withdraw it.

Yes, I was following the discussion.  But thanks for the
confirmation :-)

> I still can't see why sfq should have such a low limit, but I think,
> there is at least something to improve in the way it's imposed. BTW,
> my previous idea to check this before classifying was wrong too. But,
> IMHO, this could be done better than now like in this patch.
 ...
> [NET_SCHED] sch_sfq: prevent unnecessary reordering
> 
> Current check of queue limit in sfq_enqueue() isn't optimal: there
> is really not much more needed to prevent unnecessary dropping and
> possible reordering.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

I'll let Patrick review this one first, too.
