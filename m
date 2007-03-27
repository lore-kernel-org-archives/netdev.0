From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET] fib_rules: Flush route cache after rule modifications
Date: Tue, 27 Mar 2007 15:35:59 +0200
Message-ID: <20070327133559.GL521@postel.suug.ch>
References: <20070327132159.GK521@postel.suug.ch> <20070327133008.GE4557@rhun.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Muli Ben-Yehuda <muli@il.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56018 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbXC0Nfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:35:39 -0400
Content-Disposition: inline
In-Reply-To: <20070327133008.GE4557@rhun.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Muli Ben-Yehuda <muli@il.ibm.com> 2007-03-27 15:30
> That looks like a bug - shouldn't we flush the cache first, then do
> the rules_ops_put()?

Good catch, it's unlikely to happen but it is a bug.
