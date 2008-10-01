From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Wed, 01 Oct 2008 02:59:35 -0700 (PDT)
Message-ID: <20081001.025935.257260146.davem@davemloft.net>
References: <20080930144203.GA2511@ami.dom.local>
	<20080930145710.GB2511@ami.dom.local>
	<48E24341.5050609@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYJAJ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:59:47 -0400
In-Reply-To: <48E24341.5050609@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 30 Sep 2008 17:18:25 +0200

> Jarek Poplawski wrote:
> > On Tue, Sep 30, 2008 at 04:42:04PM +0200, Jarek Poplawski wrote:
> >> Benjamin Thery wrote, On 09/30/2008 01:52 PM:
> > ...
> >>> I'm still looking at why the first dst_free() on those particular routes doesn't call dst_destroy() immediately but defers it (another refcount
> >>> on the route itself).
> >> Yes, finding/fixing this, if possible, in this place looks like the
> >> most consistent with the way netdev_wait_allrefs() is handling this.
> > Actually, I wonder, why we can't simply run this dst_gc_task() from
> > dst_dev_event() (after cancelling the work) when needed.
> > 
> 
> Um... I haven't thought about this. I'll have a look to see if it can
> solve our issue.

Let me know what happens, I'd like to apply some fix soon.
So just report the patch implementing the final approach you
feel the most comfortable with.

Thanks.
