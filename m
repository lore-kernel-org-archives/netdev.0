From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/33] netdev: introduce dev_get_stats()
Date: Wed, 19 Nov 2008 21:40:57 -0800 (PST)
Message-ID: <20081119.214057.200155427.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234354.948324675@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751473AbYKTFk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:40:57 -0500
In-Reply-To: <20081117234354.948324675@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:09 -0800

> In order for the network device ops get_stats call to be immutable, the handling
> of the default internal network device stats block has to be changed. Add a new
> helper function which replaces the old use of internal_get_stats.
> 
> Note: change return code to make it clear that the caller should not
> go changing the returned statistics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
