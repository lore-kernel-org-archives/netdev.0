From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Inline net_device_stats
Date: Wed, 28 Mar 2007 14:26:10 -0700 (PDT)
Message-ID: <20070328.142610.52167631.davem@davemloft.net>
References: <1175073418.12230.52.camel@localhost.localdomain>
	<460A8F38.1050106@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753061AbXC1V0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 17:26:10 -0400
In-Reply-To: <460A8F38.1050106@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 28 Mar 2007 08:52:24 -0700

> It would make sense to do it per-cpu and 64 bit for the non-error
> counters.

Good point, but that's a seperate change.

I have no real objection to Rusty's change and if more than
one driver uses this thing it's useful, so I'll apply his
patch.
