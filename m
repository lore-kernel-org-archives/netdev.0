From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] NET_SCHED: restore HZ value to /proc/net/psched
Date: Fri, 27 Jun 2008 19:59:03 -0700 (PDT)
Message-ID: <20080627.195903.105671917.davem@davemloft.net>
References: <485FFB28.7070503@trash.net>
	<20080623134551.24246494@extreme>
	<48603CB9.60509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752179AbYF1C7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 22:59:03 -0400
In-Reply-To: <48603CB9.60509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Jun 2008 02:15:53 +0200

> Stephen Hemminger wrote:
> > On Mon, 23 Jun 2008 21:36:08 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> >> Stephen Hemminger wrote:
> >> - add a new proc file to get the value of kernel HZ (the
> >>    fix needs a kernel change anyway, this would additionally
> >>    require a new iproute version).
> > 
> > Don't like this might encourage new bad ABI's.
> 
> Me neither, it was just an ugly alternative to the API
> change, but on second though I'm even more convinced
> that the metrics should be fixed.

I just read over this thread and the my conclusion is the
same as Patrick's, let's fix the metrics.

I'm therefore dropping the RFC patch that started this discussion.
