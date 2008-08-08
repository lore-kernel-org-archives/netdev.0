From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Thu, 07 Aug 2008 23:03:34 -0700 (PDT)
Message-ID: <20080807.230334.239030482.davem@davemloft.net>
References: <489BCB1A.5040100@cn.fujitsu.com>
	<489BE0DA.80306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752601AbYHHGDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 02:03:35 -0400
In-Reply-To: <489BE0DA.80306@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 08 Aug 2008 13:59:54 +0800

> Yang Hongyang wrote:
> > when I use getsockopt(sk, IPPROTO_IPV6, IPV6_2292PKTOPTIONS,(char *)incmsg, &cnt)
> > to get receiving interface index while no message is received,
> > 
> > What interface index should be returned?
> 
> When get receiving interface index while no message is received,
> the bounded device's index of the socket should be returned?
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

To me it seems to be an undefined operation.

One cannot expect something valid from this socket option until a
packet really is received on the socket.
