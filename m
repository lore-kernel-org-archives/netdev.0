From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add a statistics counter for tx hash miss
Date: Mon, 21 Jul 2008 18:44:07 +0200
Message-ID: <20080721164407.GC29543@basil.nowhere.org>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org> <1216630088-10328-2-git-send-email-andi@firstfloor.org> <20080721.093330.153507902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:13106 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbYGUQoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:44:11 -0400
Content-Disposition: inline
In-Reply-To: <20080721.093330.153507902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 09:33:30AM -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon, 21 Jul 2008 10:48:08 +0200
> 
> > Add a counter for the case when the TX hash function doesn't work.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> This is very much not an IPV4 protocol statistic.
> 
> I understand your desire to export this information, but
> as easy as this method is it's not the right way.

It's IPv4 and IPv6 and netstat contains Ipv4 and ipv6 information
(e.g. all the TCP counters) and even some completely protocol independent 
counters like ArpFilter.

-Andi
