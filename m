From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 13:29:36 -0400 (EDT)
Message-ID: <20121029.132936.191100167150004535.davem@davemloft.net>
References: <1351493366.8221.2.camel@cr0>
	<1351494334.7394.64.camel@edumazet-glaptop>
	<1351495523.8221.8.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab2J2R3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 13:29:37 -0400
In-Reply-To: <1351495523.8221.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 29 Oct 2012 15:25:23 +0800

> But this will be a problem if someone moved dst inside rt, as there
> is no comment saying dst has to be the first one?

If we move the initial dst member, many things that depend upon it
being first will have to change.

Your change was unnecessary and inappropriate, and let's just leave
it at that.

Thanks.
