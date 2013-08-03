From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH v2] fib_rules: add route suppression based on ifgroup
Date: Sat, 3 Aug 2013 14:25:19 +0200
Message-ID: <20130803122519.GO21970@zirkel.wertarbyte.de>
References: <20130802151956.GK21970@zirkel.wertarbyte.de>
 <20130802.152457.2096924772877120236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:58167 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab3HCMZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 08:25:22 -0400
Content-Disposition: inline
In-Reply-To: <20130802.152457.2096924772877120236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb David Miller (davem@davemloft.net):

> > This change adds the ability to suppress a routing decision based upon the
> > interface group the selected interface belongs to. This allows it to
> > exclude specific devices from a routing decision.
> > 
> > Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
> 
> Looks fine, applied, thanks.

Whoops, there's a small glitch in that patch regarding the default values;
all default rules actually suppress routes leading to devices in the
default group; I've tidied it up in the patch just transmitted.
