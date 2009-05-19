From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] myri10ge: allow LRO to be enabled via ethtool
Date: Tue, 19 May 2009 14:28:15 -0700 (PDT)
Message-ID: <20090519.142815.254262277.davem@davemloft.net>
References: <4A131364.5050402@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43509
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751248AbZESV2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:28:17 -0400
In-Reply-To: <4A131364.5050402@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Tue, 19 May 2009 22:15:32 +0200

> Allow myri10ge LRO to be enabled/disabled via ethtool
> (and by the stack for packet forwarding).
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Please also get rid of the module option.  It being there sets
a bad precedent, and others are going to point at your driver
when they try to add such a turd to their's.

Thanks.
