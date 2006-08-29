From: David Miller <davem@davemloft.net>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 02:54:00 -0700 (PDT)
Message-ID: <20060829.025400.37356422.davem@davemloft.net>
References: <20060829082435.GA2676@suse.de>
	<20060829.183426.52410264.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40107
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964851AbWH2JyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 05:54:16 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060829.183426.52410264.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 29 Aug 2006 18:34:26 +0900 (JST)

> Further analysis is needed, but one idea is to skip
> addrconf_dev_config() if !(dev->flags & IFF_MULTICAST).

Yes, it is logical because without multicast IPV6 cannot
work correctly.

But from another perspective (I assume these bridged Xen devices use
ARPHRD_ETHER, do they?) a device with ARPHRD_ETHER and cleared
IFF_MULTICAST flag seems potentially problematic.  How many other
things break over such a device?
