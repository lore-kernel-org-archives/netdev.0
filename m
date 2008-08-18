From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Sun, 17 Aug 2008 22:41:36 -0700 (PDT)
Message-ID: <20080817.224136.118970422.davem@davemloft.net>
References: <489BE0DA.80306@cn.fujitsu.com>
	<20080807.230334.239030482.davem@davemloft.net>
	<489C5EFC.6030006@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750848AbYHRFlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 01:41:37 -0400
In-Reply-To: <489C5EFC.6030006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 08 Aug 2008 10:58:04 -0400

> For RFC 3542 style,  there what should be done:
> 
>    Issuing getsockopt() for the above options will return the sticky
>    option value i.e., the value set with setsockopt().  If no sticky
>    option value has been set getsockopt() will return the following
>    values:
> 
>    -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
>       structure with ipi6_addr being in6addr_any and ipi6_ifindex being
>       zero.

Ok so it looks like Yang's patch is ok.

Yank please resubmit your patch, thank you.
