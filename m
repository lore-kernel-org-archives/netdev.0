From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Wed, 10 Sep 2008 17:00:06 -0700 (PDT)
Message-ID: <20080910.170006.65586950.davem@davemloft.net>
References: <1221081539.3804.33.camel@johannes.berg>
	<20080910.164009.92497081.davem@davemloft.net>
	<1221091053.3804.53.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49238
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752357AbYIKAAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 20:00:12 -0400
In-Reply-To: <1221091053.3804.53.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 11 Sep 2008 01:57:33 +0200

> And then they time out after 30 seconds? I see the message exactly three
> times and then it gets removed.

That's how often garbage collection runs on ICMP6 routes.
