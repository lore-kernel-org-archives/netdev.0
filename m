From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast
 destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Tue, 23 May 2006 16:53:43 -0700 (PDT)
Message-ID: <20060523.165343.104035136.davem@davemloft.net>
References: <200605232316.k4NNGRBp001431@fire-2.osdl.org>
	<20060523163142.4149e06f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47775
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932109AbWEWXy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 19:54:29 -0400
To: akpm@osdl.org
In-Reply-To: <20060523163142.4149e06f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Tue, 23 May 2006 16:31:42 -0700

> >            Summary: dummy interface broadcast destination hardware address
> >                     is not ff:ff:ff:ff:ff:ff

Very strange because the dummy device driver calls
ether_setup() which does:

	memset(dev->broadcast,0xFF, ETH_ALEN);

Probably tcpdump does not understand the link type, but that
also doesn't make sense since clearly the ifconfig output shows
"Ethernet" as the link encapsulation type.

Stumped...

