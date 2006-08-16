From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 14:08:08 +0200
Message-ID: <20060816120808.GA14627@postel.suug.ch>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816113950.GA29003@gondor.apana.org.au> <1155729864.5122.95.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:14994 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751131AbWHPMHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 08:07:47 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155729864.5122.95.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-08-16 08:04
> current->pid i think is coming out to be a bad idea. Thomas' patches
> revert it out. Again this has everything to do with the original idea
> what maps to pid now changing to socketid.

It probably developed from autobind using current->tid.
