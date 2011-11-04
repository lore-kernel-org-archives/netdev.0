From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add wireless TX status socket option
Date: Fri, 04 Nov 2011 17:51:08 -0400 (EDT)
Message-ID: <20111104.175108.472681560571826562.davem@davemloft.net>
References: <1320317796.3950.43.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413Ab1KDVwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:52:12 -0400
In-Reply-To: <1320317796.3950.43.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 03 Nov 2011 11:56:36 +0100

 ...
> To get rid of that hack, introduce a real wifi TX
> status option for data frame transmissions.
> 
> This works similar to the existing TX timestamping
> in that it reflects the SKB back to the socket's
> error queue with a SCM_WIFI_STATUS cmsg that has
> an int indicating ACK status (0/1).
 ...
> I'd like to merge this through the wireless tree since
> some new features sort of depend on it. Thoughts?

No objections, feel free to put this into the wireless tree.
