From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 13:23:14 +0000
Message-ID: <20110112132314.GA9920@ff.dom.local>
References: <20110112122811.GA9513@ff.dom.local> <1294837632.3981.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Brownell <david-b@pacbell.net>,
	=?iso-8859-2?Q?Micha=B3?= Nazarewicz <m.nazarewicz@samsung.com>,
	Neil Jones <neiljay@gmail.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49897 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295Ab1ALNXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 08:23:21 -0500
Content-Disposition: inline
In-Reply-To: <1294837632.3981.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 12, 2011 at 02:07:12PM +0100, Eric Dumazet wrote:
...
> 
> Hmm... 
> 
> So all net devices in gen_ndis_query_resp() should have a
> ndo_get_stats() or ndo_get_stats64() method, not allowed to use
> spin_lock_bh() / spin_unlock_bh()
> 
> If yes, we should add big fat comments to pn_net_stats()/eth_get_stats() so that nobody
> tries to revert your patch ;)

I'm not sure I got your point: my patch could be replaced with
ndo_get_stats64() implementing irq safe locking or by changing
gen_ndis_query_resp() calling context. It's intended as a fast
(compatible) fix.

Jarek P.
