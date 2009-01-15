From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SIS900 show warning if bogus MAC address (take 2)
Date: Wed, 14 Jan 2009 20:46:47 -0800 (PST)
Message-ID: <20090114.204647.247000830.davem@davemloft.net>
References: <20090113181821.GA21342@milesteg.arr>
	<20090113154407.9d2fe57c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755325AbZAOEqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:46:45 -0500
In-Reply-To: <20090113154407.9d2fe57c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 13 Jan 2009 15:44:07 -0800

> On Tue, 13 Jan 2009 19:18:21 +0100
> Daniele Venzano <venza@brownhat.org> wrote:
> >
> > Subject: [PATCH] SIS900 show warning if bogus MAC address (take 2)
> >
> 
> The title is now wrong.  I rewrote it in my copy to
> 
> sis900: generate fake MAC address if the hardware doesn't have one

I've applied this patch with this correction to net-2.6

> So we generate the fake address a) if the reading failed and b) if the
> reading succeeded, but returned a bad address.
> 
> Fair enough, I guess.  I wonder if other drivers implement that policy.

Several do.
