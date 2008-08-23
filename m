From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sat, 23 Aug 2008 05:15:21 -0700 (PDT)
Message-ID: <20080823.051521.138508140.davem@davemloft.net>
References: <20080821125501.GF4079@ff.dom.local>
	<20080821131218.GA9208@gondor.apana.org.au>
	<20080821185857.GA2665@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58180
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753004AbYHWMPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 08:15:23 -0400
In-Reply-To: <20080821185857.GA2665@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 21 Aug 2008 20:58:57 +0200

> sch_tree_lock() should be enough for now because in the current
> implementation we have only one root qdisc with pointers copied to
> every dev_queue. At least I can't see nothing more in qdisc_create()
> and qdisc_graft(). So, qdisc_lookup() seems to be designed for the
> future (or to do this lookup more exactly with additional loops...).

Yes, I designed it for the future.

Nothing really uses this capability currently.
