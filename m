From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Fri, 18 Apr 2008 04:09:49 -0700 (PDT)
Message-ID: <20080418.040949.87112742.davem@davemloft.net>
References: <480878CE.5040904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51811
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbYDRLJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 07:09:48 -0400
In-Reply-To: <480878CE.5040904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 18 Apr 2008 18:32:46 +0800

> As RFC3542 mentions: An attempt to set IPV6_CHECKSUM for an
> ICMPv6 socket will fail.
> Add a check for that in do_rawv6_setsockopt().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Enforcing these kinds of things we've allowed for so many years is
rather pointless, especially if it breaks real applications.  Which I
believe it does in this case.  The standards simply do not matter.

I seem to recall that traceroute6 in iputils does exactly this.
