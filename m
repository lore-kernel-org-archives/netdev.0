From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20.y & net-2.6] [IPV6] HASHTABLES: Use appropriate
 seed for caluculating ehash index.
Date: Mon, 12 Feb 2007 20:26:10 -0800 (PST)
Message-ID: <20070212.202610.85412065.davem@davemloft.net>
References: <20070213.094841.17517365.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, handat@pm.nttdata.co.jp
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbXBME0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 23:26:13 -0500
In-Reply-To: <20070213.094841.17517365.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 13 Feb 2007 09:48:41 +0900 (JST)

> Tetsuo Handa <handat@pm.nttdata.co.jp> told me that connect(2) with TCPv6
> socket almost always took a few minutes to return when we did not have any
> ports available in the range of net.ipv4.ip_local_port_range.
> 
> The reason was that we used incorrect seed for calculating index of
> hash when we check established sockets in __inet6_check_established().
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thank you for this bug fix, applied.

Here is my signoff for -stable.

Signed-off-by: David S. Miller <davem@davemloft.net>
