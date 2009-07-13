From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general][PATCH] mlx4_core: Synch catastrophic flow with module unload
Date: Mon, 13 Jul 2009 12:45:32 -0700
Message-ID: <adak52cv02r.fsf@cisco.com>
References: <4A5B5274.2020801@mellanox.co.il>
	<20090713.111407.196601373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yevgenyp@mellanox.co.il, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:37611 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906AbZGMTpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 15:45:33 -0400
In-Reply-To: <20090713.111407.196601373.davem@davemloft.net> (David Miller's
	message of "Mon, 13 Jul 2009 11:14:07 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Applied, thanks.

Dave, please don't apply mlx4_core patches without giving me a chance to
review them.  In this case the patch looks buggy to me: I don't see how
it handles, say, hot remove of one device -- it only handles module
removal.  And I would hope we could fix this without adding a global
symbol as namespace polluting as "drv_mutex".

Yevgeny didn't even send this patch to you; he just cc'ed netdev as a
courtesy.  However I understand that the physical location of mlx4_core
in drivers/net makes it easy to do this.  Maybe this is the best
argument in favor of moving the mlx4_core stuff to drivers/shared?

 - R.
