From: David Miller <davem@davemloft.net>
Subject: Re: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 10 Jul 2007 11:36:12 -0700 (PDT)
Message-ID: <20070710.113612.51855247.davem@davemloft.net>
References: <20070710085640.128311d1@freepuppy.rosehill.hemminger.net>
	<20070710.110545.112620737.davem@davemloft.net>
	<4693CD28.5070402@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763771AbXGJSft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 14:35:49 -0400
In-Reply-To: <4693CD28.5070402@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Tue, 10 Jul 2007 12:17:12 -0600

> It's rather ironic that the "new-and-improved" way of doing things is 
> subject to rollover while the "old" way is not.

Text is always more flexible, but is hard to extend.

We can trivially add "u64" statistics to netlink.
