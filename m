From: Jain Priyanka-B32167 <B32167@freescale.com>
Subject: RE: [PATCH][XFRM][v2] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Fri, 10 Aug 2012 04:29:46 +0000
Message-ID: <AC83832D6324604BB08FAE5A33553F1907A9B384@039-SN2MPN1-012.039d.mgd.msft.net>
References: <1344493315-2505-1-git-send-email-Priyanka.Jain@freescale.com>
 <20120809.161508.1611476184890758249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.185] ([216.32.181.185]:21201 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751110Ab2HJEbB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 00:31:01 -0400
In-Reply-To: <20120809.161508.1611476184890758249.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
Sent: Friday, August 10, 2012 4:45 AM
To: Jain Priyanka-B32167
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH][XFRM][v2] Replace rwlock on xfrm_policy_afinfo with rcu

From: Priyanka Jain <Priyanka.Jain@freescale.com>
Date: Thu, 9 Aug 2012 11:51:55 +0530

> +	local_bh_disable();
> +	rcu_read_lock();

This is "rcu_read_lock_bh()"
[Priyanka] will correct this in v3. 

Also I do not believe you addressed any of Eric Dumazet's feedback.
[Priyanka] Will send v3 after closing on Eric Dumazet's feedback. Thanks
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
