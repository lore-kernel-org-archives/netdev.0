From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Sun, 20 Apr 2008 02:37:45 -0700 (PDT)
Message-ID: <20080420.023745.83249692.davem@davemloft.net>
References: <20080420.003328.45324753.davem@davemloft.net>
	<480B0A59.7000408@cn.fujitsu.com>
	<20080420.183835.02139171.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753401AbYDTJho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 05:37:44 -0400
In-Reply-To: <20080420.183835.02139171.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 20 Apr 2008 18:38:35 +0900 (JST)

> RFC3542 only tells about IPPROTO_IPV6-level IPV6_CHECKSUM option only
> while ping6 and traceroute6 use IPPROTO_RAW-level IPV6_CHECKSUM
> option.  Just disallow setting those on IPPROTO_IPV6 level.

Now that's a lot more reasonable, I think I'll apply
this patch, thanks.
