From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist
 outgoing interface
Date: Mon, 02 Jun 2008 18:17:45 +0900 (JST)
Message-ID: <20080602.181745.29009203.yoshfuji@linux-ipv6.org>
References: <4843AB51.6010206@cn.fujitsu.com>
	<20080602.172009.84304151.yoshfuji@linux-ipv6.org>
	<4843B65C.1060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: shanwei@cn.fujitsu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57950 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbYFBJRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 05:17:10 -0400
In-Reply-To: <4843B65C.1060702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4843B65C.1060702@cn.fujitsu.com> (at Mon, 02 Jun 2008 16:59:08 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

>   When specifying the outgoing interface with sendmsg, if the ipi6_addr is 
> the unspecified address and the ipi6_ifindex is the not-exist interface, 
> it should be fail and the errno should be set ENODEV.
>   Actually, it does well(sendmsg returns on success ), because the kernel 
> don't check the interface。
> 
>  The patch is against 2.6.26-rc4.
> 
> Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>

Patch (white spaces) is broken, but I'm going to apply this by hand.
Thanks.

--yoshfuji
