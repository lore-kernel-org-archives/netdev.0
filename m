From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 09 Oct 2008 22:25:26 -0700 (PDT)
Message-ID: <20081009.222526.63311979.davem@davemloft.net>
References: <20081009212755.94fe11f6.akpm@linux-foundation.org>
	<20081009.215452.193703022.davem@davemloft.net>
	<20081009221647.8026269d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39252
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752225AbYJJFZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 01:25:50 -0400
In-Reply-To: <20081009221647.8026269d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 9 Oct 2008 22:16:47 -0700

> The stephen/me function is a single point of failure and right now,
> it has failed.  I have to push back.

It seems to go perfectly smooth when I interact with Stephen on these
kinds of situations.

He just says "this broke/conflicts, please fix it", I do exactly that
and we move on.  Rinse, repeat.

And I don't think there is any kind of problem with that.  We have
multiple levels of checks, and we end up catching it %99.999 of
the time before it hits Linus's tree and we fixup whatever slips
through.

Otherwise we could skip the whole -rc thing :-)
