From: David Miller <davem@davemloft.net>
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 13:00:11 -0700 (PDT)
Message-ID: <20070425.130011.21926881.davem@davemloft.net>
References: <20070425122924.88391585.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993008AbXDYUAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:00:04 -0400
In-Reply-To: <20070425122924.88391585.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 25 Apr 2007 12:29:24 -0700

> 
> I note that the networking tree is adding new sysctls:
> 
> <<<<<<< HEAD/include/linux/sysctl.h
>         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> =======
>         NET_IPV6_OPTIMISTIC_DAD=24,
>         NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> >>>>>>> /include/linux/sysctl.h
> 
> (Well, it's trying to - there are some git rejects in net-2.6.22)

I knew this was going to happen because of Yoshifuji's
security fix, the conflict is trivial to resolve.

I'll rebase the net-2.6.22 tree later today since all
we should have before 2.6.21-final is the netlink
OOPS'er fix Alexey just posted.
