From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/6] ipv6: use timer pending
Date: Mon, 21 Jul 2008 16:16:15 -0700
Message-ID: <488518BF.1090207@candelatech.com>
References: <20080721192834.221648982@vyatta.com> <20080721192919.971385103@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46711 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbYGUXQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 19:16:22 -0400
In-Reply-To: <20080721192919.971385103@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This fixes the bridge reference count problem and cleanups ipv6 FIB timer management.
> Don't use expires field, because it is not a proper way to test,
> instead use timer_pending().

I patched this into my 2.6.25, and it does not seem to help
my refcount problem.  I did not apply any of your other
patches as it seemed they were mostly cleanups.

This is not to say that this patch is wrong...but
it seems we'll have to keep looking for other problems
as well.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

