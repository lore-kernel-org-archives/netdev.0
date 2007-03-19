From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 12:34:43 +0300
Message-ID: <20070319093443.GC9387@ms2.inr.ac.ru>
References: <20070318224234.GP11078@mellanox.co.il> <20070318.171337.112622504.davem@davemloft.net> <m3aby94x6o.fsf@maxwell.lnxi.com> <20070318.231316.59470365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederman@lnxi.com, mst@dev.mellanox.co.il,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54702 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751267AbXCSJfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 05:35:02 -0400
Content-Disposition: inline
In-Reply-To: <20070318.231316.59470365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I think the thing to do is to just leave the loopback references
> in place, try to unregister the per-namespace loopback device,
> and that will safely wait for all the references to go away.

Yes, it is exactly how it works in openvz. All the sockets are killed,
queues are cleared, nobody holds references and virtual loopback
can be unregistered just like another device.

Alexey
