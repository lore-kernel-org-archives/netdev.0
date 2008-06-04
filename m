From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] [SCTP]: Fix ECN markings for IPv6
Date: Wed, 04 Jun 2008 12:40:25 -0700 (PDT)
Message-ID: <20080604.124025.29833100.davem@davemloft.net>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
	<1212603951-24932-7-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758471AbYFDTk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:40:26 -0400
In-Reply-To: <1212603951-24932-7-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  4 Jun 2008 14:25:51 -0400

> Commit e9df2e8fd8fbc95c57dbd1d33dada66c4627b44c
> ([IPV6]: Use appropriate sock tclass setting for routing lookup.) also
> changed the way that ECN capable transports mark this capability in IPv6.
> As a result, SCTP was not marking ECN capablity because the traffic class
> was never set.  This patch brings back the markings for IPv6 traffic.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied, thanks a lot Vlad!
