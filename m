From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr
 to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: Tue, 01 May 2007 01:09:27 +0900 (JST)
Message-ID: <20070501.010927.01623782.yoshfuji@linux-ipv6.org>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33400 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423854AbXD3QJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 12:09:24 -0400
In-Reply-To: <20070430162851.ca3c7869.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070430162851.ca3c7869.dada1@cosmosbay.com> (at Mon, 30 Apr 2007 16:28:51 +0200), Eric Dumazet <dada1@cosmosbay.com> says:

> On 64bit arches, we can speedup some IPV6 addresses compares, using 64 bits fields in struct in6_addr.
> 
> I am not sure if this patch wont break some user ABI, maybe we should use some ifdef(KERNEL) ?

AFAIK, it did and I guess it will.  So, please do not do this even though
it is enclosed with ifdef(__KERNEL__), so far, at least, for 2.6.22.

--yoshfuji
