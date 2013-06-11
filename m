From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] bonding: couple of bug fixes
Date: Tue, 11 Jun 2013 02:45:30 -0700 (PDT)
Message-ID: <20130611.024530.1458814488844049119.davem@davemloft.net>
References: <1370519702-18581-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab3FKJpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:45:31 -0400
In-Reply-To: <1370519702-18581-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nikolay@redhat.com
Date: Thu,  6 Jun 2013 13:55:00 +0200

> From: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Hello,
> Patch 01 resets the master's mac if the first enslave fails and the slave's
> mac was set to the master's prior.
> Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
> param and was silently not working if the value was >127) so it can go up to 255
> (as per documentation). It also fixes two tricky race conditions which were
> hidden because of the previous bug.

There was some minor back and forth between Jay and Nikolay on this set,
but I'd like to see some ACKs before applying this stuff.

Thanks.
