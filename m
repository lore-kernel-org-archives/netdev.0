From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Tue, 20 Feb 2007 23:15:45 -0800 (PST)
Message-ID: <20070220.231545.104035801.davem@davemloft.net>
References: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932765AbXBUHPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:15:47 -0500
In-Reply-To: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 15 Feb 2007 02:35:14 +0900 (JST)

> Please consider pulling the following changesets available on the
> 	2.6.20-net-2.6-20070214-FOR_DAVEM
> branch at
> 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
> (on top of commit 928ba4169dc1d82c83105831f5ddb5472379b440).

Unfortunately, the merge window is closed so I really cannot merge all
of this, only bug fixes at this point.

If you would like to avoid this, please be more prompt in merging to
me next time the merge window opens up.

I think changes such as:

    [IPV6] ADDRCONF: Manage prefix route corresponding to address manually added.
    [IPV6] IP6TUNNEL: Use update_pmtu() of dst on xmit.
 ...
    [IPV6] ADDRCONF: Register inet6_dev earlier.

could be merged to 2.6.20 as bug fixes, but the rest are cleanups and
new functionality so would need to be left out.

Thank you.
