From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Thu, 7 Dec 2006 11:47:21 +0100
Message-ID: <20061207104721.GI8693@postel.suug.ch>
References: <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <200612062033.34754.stefan@loplof.de> <20061206.165638.30168567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan@loplof.de, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52764 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032009AbWLGKrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:47:00 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061206.165638.30168567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-12-06 16:56
> That's enough for me.
> 
> Thomas we need to restore things to how they were before.
> If that means including if_addr.h from rtnetlink.h so be it.
> 
> We can't break shit like this, there are no excuses, especially
> now that we properly frob the headers for userspace consumption
> in the kernel tree.

So you want to restore IFLA_RTA/IFLA_PAYLOAD etc. as well?
