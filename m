From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Sat, 29 Dec 2007 19:22:12 -0800 (PST)
Message-ID: <20071229.192212.149111967.davem@davemloft.net>
References: <20071225124323.70e0c772@deepthought>
	<20071225.150238.193724414.davem@davemloft.net>
	<20071225171310.1c43a0e2@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752920AbXL3DWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 22:22:15 -0500
In-Reply-To: <20071225171310.1c43a0e2@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 25 Dec 2007 17:13:10 -0800

> Well changing netinet/tcp.h is just not a realistic proposition, it takes
> too long to filter from glibc through distro's to be worth it.

But you have to, the ifdef mess you are suggesting is so much
worse.

Look at the reason you even have to do add the ifdefs, it's because
lo' and behold the congestion control defines have already propagated
properly into netinet/tcp.h

And this alone proves that your argument against putting this stuff in
the right place has no basis in reality.

Please just submit a patch to the appropriate place to get the
interfaces you need into netinet/tcp.h included instead of crapping
all over the kernel headers.

In the interum you can put a special header into the iproute2
distribution to handle this until it's sorted.
