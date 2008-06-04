From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/3] [IPV6]: Do not change protocol for raw IPv6
 sockets.
Date: Wed, 04 Jun 2008 21:53:13 +0900 (JST)
Message-ID: <20080604.215313.129699155.yoshfuji@linux-ipv6.org>
References: <1212580148-9885-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58083 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbYFDMwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:52:36 -0400
In-Reply-To: <1212580148-9885-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212580148-9885-1-git-send-email-den@openvz.org> (at Wed,  4 Jun 2008 15:49:06 +0400), "Denis V. Lunev" <den@openvz.org> says:

> It is not allowed to change underlying protocol for
>    int fd = socket(PF_INET6, SOCK_RAW, IPPROTO_UDP);
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied for net-2.6 and stable, thanks.

--yoshfuji
