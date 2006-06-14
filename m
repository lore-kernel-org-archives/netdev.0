From: Ben Greear <greearb@candelatech.com>
Subject: Offering presents for more routing tables!
Date: Wed, 14 Jun 2006 06:45:51 -0700
Message-ID: <4490130F.3030005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:5012 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S964926AbWFNNpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 09:45:52 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k5EDjpmP002348
	for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 06:45:52 -0700
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've asked for this feature several years ago and evidently
it is not trivial to increase the number of routing tables.

But, perhaps someone now has time & inclination?

I would like to have more (a few thousand) routing tables
available in the kernel so that I can use a routing table for
each of my many VLANs.  Currently, the netlink protocol only
specifies an 8-bit id for the routing table:
http://www.faqs.org/rfcs/rfc3549.html  Section 3.1.1
so a new netlink message would need to be created and the 'ip' tool
updated.  I think at least a 16-bit identifier should be used,
possibly a full 32 bits so we don't have to revisit this again for
a while!

The kernel itself would also need to be modified so that it can
have more routing tables.  I realize most people don't need a
large number of tables, so the maximum number should be configured
at either compile time or run time.

If I remember right, there are certain tables (253 - 255) that
are currently special in the kernel.  For complete backwards compatibility,
this hole would probably have to remain as it is, with the new
tables starting at 256.

I would be willing to help test any resulting patches, and can
also offer bribes of money, hardware, beer, etc.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

