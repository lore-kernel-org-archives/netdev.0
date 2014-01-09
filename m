From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 09 Jan 2014 15:19:57 -0500 (EST)
Message-ID: <20140109.151957.1618381015670153898.davem@davemloft.net>
References: <2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
	<20140109.143923.437905458430188006.davem@davemloft.net>
	<25B12960-1709-4E96-A278-9DBF9009C0F5@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@cumulusnetworks.com, aaron.f.brown@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: mark.d.rustad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbaAIUUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:20:00 -0500
In-Reply-To: <25B12960-1709-4E96-A278-9DBF9009C0F5@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Date: Thu, 9 Jan 2014 20:14:51 +0000

> Obviously I could do it here, but I *really* think it is
> procedurally a really bad idea to change the case as part of a
> functional change. I thought I was doing a favor my at least making
> them inlines, but prehaps not.

It is never a good idea to allow functions to have all caps
names and vice versa.  Please don't use "difficulty" as a reason
to violate this.

Doing things right is sometimes hard, I'm sorry to inform you :)

> Anyone want to take on changing the upper case static inlines in
> mcf8390, 7990, benet, ns83820, s2io, vxge, iwlwifi, ath9k, wil6210,
> mwifiex, and rtlwifi? And those are just under drivers/net.

Sorry the "crap exists elsewhere, therefore I can make crap too"
argument never holds any water.

Just because crap exists elsewhere, doesn't mean you should duplicate it.
