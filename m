From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Thu, 24 Apr 2008 21:46:39 -0700 (PDT)
Message-ID: <20080424.214639.189928746.davem@davemloft.net>
References: <20080424.211953.52921169.yoshfuji@linux-ipv6.org>
	<200804241826.52507.rdenis@simphalempin.com>
	<48112DFF.8020003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdenis@simphalempin.com, yoshfuji@linux-ipv6.org,
	ellre923@gmail.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750930AbYDYEqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 00:46:42 -0400
In-Reply-To: <48112DFF.8020003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 25 Apr 2008 09:03:59 +0800

> David, should we make sure every common used userland package
> will not be influenced by this change?
> No influence packages:
> iputils
> iproute2
> ndisc6
> net-tools

I don't think it is necessary to maintain a list.

If problems crop up and get reported, we should just focus
on fixing them.
