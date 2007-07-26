From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193
 addresses
Date: Thu, 26 Jul 2007 13:34:52 -0500 (CDT)
Message-ID: <20070726.133452.78498553.yoshfuji@linux-ipv6.org>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com, yoshfuji@linux-ipv6.org
To: djohnson+linux-kernel@sw.starentnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49321 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763128AbXGZSeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:34:04 -0400
In-Reply-To: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <18087.57717.495366.413571@zeus.sw.starentnetworks.com> (at Wed, 25 Jul 2007 19:49:09 -0400), Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com> says:

> ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
> Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I would say, it would be better to add IPV6_ADDR_UNICAST as well
for "reserved" addresses unless we have good reason not to do it,
anyway.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
