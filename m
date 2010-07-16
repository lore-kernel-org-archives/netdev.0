From: David Miller <davem@davemloft.net>
Subject: Re: [ipmr] ipmr: Don't leak memory if fib lookup fails.
Date: Thu, 15 Jul 2010 22:39:15 -0700 (PDT)
Message-ID: <20100715.223915.91352309.davem@davemloft.net>
References: <1279236153-23699-1-git-send-email-greearb@candelatech.com>
	<4C3FA22A.7090706@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48328
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504Ab0GPFjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 01:39:00 -0400
In-Reply-To: <4C3FA22A.7090706@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 15 Jul 2010 17:04:58 -0700

> On 07/15/2010 04:22 PM, Ben Greear wrote:
>> This was detected using two mcast router tables.  The
>> pimreg for the second interface did not have a specific
>> mrule, so packets received by it were handled by the
>> default table, which had nothing configured.
> 
> I just realized this should be applied against 2.6.35-pre, not 2.6.34.

Fix looks good, applied to net-2.6, thanks!
