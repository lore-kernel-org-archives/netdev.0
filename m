From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/2] pkt_sched: Fix locking of qdisc_root with
 qdisc_root_sleeping_lock()
Date: Fri, 29 Aug 2008 14:22:07 -0700 (PDT)
Message-ID: <20080829.142207.149770916.davem@davemloft.net>
References: <20080826205829.GA2555@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758974AbYH2VWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 17:22:12 -0400
In-Reply-To: <20080826205829.GA2555@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 26 Aug 2008 22:58:29 +0200

> pkt_sched: Fix locking of qdisc_root with qdisc_root_sleeping_lock()
> 
> Use qdisc_root_sleeping_lock() instead of qdisc_root_lock() where
> appropriate. The only difference is while dev is deactivated, when
> currently we can use a sleeping qdisc with the lock of noop_qdisc.
> This shouldn't be dangerous since after deactivation root lock could
> be used only by gen_estimator code, but looks wrong anyway.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks a lot Jarek.
