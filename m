From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] netns: make IPv6 multicast forwarding per-namespace
Date: Tue, 09 Dec 2008 15:53:42 -0800 (PST)
Message-ID: <20081209.155342.177338912.davem@davemloft.net>
References: <20081208160156.343758157@localhost.localdomain>
	<493EA323.5050806@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	adobriyan@gmail.com, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753565AbYLIXxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 18:53:41 -0500
In-Reply-To: <493EA323.5050806@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 09 Dec 2008 17:56:03 +0100

> While doing some more tests on the patchset I've realized that the queue
> of unresolved entries (mfc_unres_queue) should also be allocated
> per-netns (or at least counter cache_resolve_queue_len should be).
> 
> With the current patchset, the cache for unresolved entries is limited
> to 10 entries for all namespaces. D'oh.
> 
> I'm looking at this issue and  will resend the patchset with the missing
> patch ASAP.

Okie dokie.
