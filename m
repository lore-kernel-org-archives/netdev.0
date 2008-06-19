From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][PATCH] IPv6:Remove options header when setsockopt's
 optlen is 0
Date: Thu, 19 Jun 2008 16:52:18 +0900 (JST)
Message-ID: <20080619.165218.40446264.yoshfuji@linux-ipv6.org>
References: <4858AE3D.6070101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59898 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbYFSHv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 03:51:26 -0400
In-Reply-To: <4858AE3D.6070101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4858AE3D.6070101@cn.fujitsu.com> (at Wed, 18 Jun 2008 14:42:05 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

> Remove the sticky Hop-by-Hop options header by calling setsockopt() for IPV6_HOPOPTS
> with a zero option length, per RFC3542.
> 
> Routing header and Destination options header does the same as Hop-by-Hop options header. 
> 
> 
> Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
