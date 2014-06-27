From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next] LISP: Locator/Identifier Separation
 Protocol
Date: Fri, 27 Jun 2014 12:28:43 -0700 (PDT)
Message-ID: <20140627.122843.774074134481698671.davem@davemloft.net>
References: <53AD0D06.6070109@cisco.com>
	<20140627.001353.840895998677889032.davem@davemloft.net>
	<53AD1DED.3090908@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@logicalelegance.com, netdev@vger.kernel.org,
	vermagan@cisco.com
To: lojakab@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbaF0T2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 15:28:47 -0400
In-Reply-To: <53AD1DED.3090908@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lori Jakab <lojakab@cisco.com>
Date: Fri, 27 Jun 2014 10:31:57 +0300

> The OVS datapath's flow table is also influenced by traffic patterns
> sent by external hosts.  But while the IPv4 routing table is not
> optional for a networked host, OVS and LISP are, and people deploying
> them can still find value using them, in controlled environments at
> least.

You haven't shown how this is not exploitable if remote entities can
control the contents of your tables and how frequently they must be
updated.

I also worry about OVS, for the same reasons.

It isn't an answer to say that these technologies work fine if you
lock up the machine into a controlled environemt.
