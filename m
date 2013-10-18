From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/4] bridge: Fix problems around the PVID
Date: Fri, 18 Oct 2013 16:03:42 -0400 (EDT)
Message-ID: <20131018.160342.1865621134607396758.davem@davemloft.net>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	toshiaki.makita1@gmail.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003Ab3JRUDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:03:44 -0400
In-Reply-To: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Wed, 16 Oct 2013 17:07:12 +0900

> There seem to be some undesirable behaviors related with PVID.
> 1. It has no effect assigning PVID to a port. PVID cannot be applied
> to any frame regardless of whether we set it or not.
> 2. FDB entries learned via frames applied PVID are registered with
> VID 0 rather than VID value of PVID.
> 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
> This leads interoperational problems such as sending frames with VID
> 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
> 0 as they belong to VLAN 0, which is expected to be handled as they have
> no VID according to IEEE 802.1Q.
 ...
> Patch set follows this mail.
> The order of patches is not the same as described above, because the way
> to fix 1st problem is based on the assumption that we don't use VID 0 as
> a PVID, which is realized by fixing 3rd problem.
> (1/4)(2/4): Fix 3rd problem.
> (3/4): Fix 1st problem.
> (4/4): Fix 2nd probelm.
> 
> v2:
> - Add descriptions about the problem related to priority-tags in cover letter.
> - Revise patch comments to reference the newest spec.

Series applied, thank you.
