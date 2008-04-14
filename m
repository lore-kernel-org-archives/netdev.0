From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [IPV6] MROUTE: Do not call ipv6_find_idev()
 directly.
Date: Sun, 13 Apr 2008 23:21:27 -0700 (PDT)
Message-ID: <20080413.232127.166612372.davem@davemloft.net>
References: <20080413.165830.63819736.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753083AbYDNGV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:21:26 -0400
In-Reply-To: <20080413.165830.63819736.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 13 Apr 2008 16:58:30 +0900 (JST)

> Since NETDEV_REGISTER notifier chain is responsible for creating
> inet6_dev{}, we do not need to call ipv6_find_idev() directly here.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
