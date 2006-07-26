From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [IPV6]: Remove ndiscs rt6_lock dependency
Date: Wed, 26 Jul 2006 15:28:45 -0700 (PDT)
Message-ID: <20060726.152845.71540437.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221849.188750063@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64174
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751806AbWGZW2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:28:37 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221849.188750063@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:01 +0200

> (Ab)using rt6_lock wouldn't work anymore if rt6_lock is
> converted into a per table lock.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This one looks great.

Signed-off-by: David S. Miller <davem@davemloft.net>
