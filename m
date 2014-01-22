From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix some fallout from the etner_addr_copy()
 changes.
Date: Tue, 21 Jan 2014 22:54:31 -0800 (PST)
Message-ID: <20140121.225431.117378955801559296.davem@davemloft.net>
References: <20140121.190348.1653034020095660800.davem@davemloft.net>
	<20140121232331.130f34fc.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbaAVGye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 01:54:34 -0500
In-Reply-To: <20140121232331.130f34fc.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 21 Jan 2014 23:23:31 -0500

> The commit message indicates problems with appletalk/aarp.c,
> atm/lec.c, and caif/caif_usb.c, but the diffstat and patch only
> address the first two and not caif/caif_usb.c.  Is that intended
> or am I missing something.

Thanks for catching that, I just pushed the missing change.
