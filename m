From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Provide compat support for SIOCGETMIFCNT_IN6 and
 SIOCGETSGCNT_IN6.
Date: Thu, 03 Feb 2011 18:00:35 -0800 (PST)
Message-ID: <20110203.180035.70190789.davem@davemloft.net>
References: <20110203.175448.245404709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753585Ab1BDCAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 21:00:00 -0500
In-Reply-To: <20110203.175448.245404709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 03 Feb 2011 17:54:48 -0800 (PST)

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/mroute6.h |    1 +
>  net/ipv6/ip6mr.c        |   74 +++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/raw.c          |   18 +++++++++++
>  3 files changed, 93 insertions(+), 0 deletions(-)

Build testing on x86_64 showed that net/ipv6/raw.c needs a linux/compat.h
include.  I've made that change in my local repo.
