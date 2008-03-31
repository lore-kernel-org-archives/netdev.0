From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [2.6 PATCH] IPV6: Check length of optval provided by user in
 setsockopt()
Date: Mon, 31 Mar 2008 18:15:51 +0900 (JST)
Message-ID: <20080331.181551.118587102.yoshfuji@linux-ipv6.org>
References: <47F0AA16.1070900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55652 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbYCaJOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 05:14:18 -0400
In-Reply-To: <47F0AA16.1070900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47F0AA16.1070900@cn.fujitsu.com> (at Mon, 31 Mar 2008 17:08:38 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> Check length of setsockopt's optval, which provided by user, before copy it
> from user space.

Please use "<" not "==".

--yoshfuji
