From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add a statistics counter for tx hash miss
Date: Mon, 21 Jul 2008 09:51:58 -0700 (PDT)
Message-ID: <20080721.095158.127501421.davem@davemloft.net>
References: <1216630088-10328-2-git-send-email-andi@firstfloor.org>
	<20080721.093330.153507902.davem@davemloft.net>
	<20080721164407.GC29543@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751754AbYGUQv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:51:58 -0400
In-Reply-To: <20080721164407.GC29543@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Jul 2008 18:44:07 +0200

> On Mon, Jul 21, 2008 at 09:33:30AM -0700, David Miller wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Mon, 21 Jul 2008 10:48:08 +0200
> > 
> > > Add a counter for the case when the TX hash function doesn't work.
> > > 
> > > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > 
> > This is very much not an IPV4 protocol statistic.
> > 
> > I understand your desire to export this information, but
> > as easy as this method is it's not the right way.
> 
> It's IPv4 and IPv6 and netstat contains Ipv4 and ipv6 information
> (e.g. all the TCP counters) and even some completely protocol independent 
> counters like ArpFilter.

You're logging when we don't hit ipv4 or ipv6 :-)
