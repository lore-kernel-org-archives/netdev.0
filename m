From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Fri, 17 Oct 2008 20:32:21 +0200
Message-ID: <20081017183221.GA12825@one.firstfloor.org>
References: <20081013155715.GZ20815@postel.suug.ch> <873aixksf0.fsf@basil.nowhere.org> <20081017182312.GE20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52366 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbYJQSZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 14:25:22 -0400
Content-Disposition: inline
In-Reply-To: <20081017182312.GE20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> softirq_count() simply counts the levels of bh disable.

softirqs always have bh disabled.  So it's always true inside them.
And you should know what _bh locks you hold.

-Andi

-- 
ak@linux.intel.com
