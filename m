From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/3] [IPV6]: inet_sk(sk)->cork.opt leak
Date: Wed, 04 Jun 2008 21:53:57 +0900 (JST)
Message-ID: <20080604.215357.38136643.yoshfuji@linux-ipv6.org>
References: <1212580148-9885-1-git-send-email-den@openvz.org>
	<1212580148-9885-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58091 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbYFDMxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:53:19 -0400
In-Reply-To: <1212580148-9885-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212580148-9885-2-git-send-email-den@openvz.org> (at Wed,  4 Jun 2008 15:49:07 +0400), "Denis V. Lunev" <den@openvz.org> says:

> IPv6 UDP sockets wth IPv4 mapped address use udp_sendmsg to send the data
> actually. In this case ip_flush_pending_frames should be called instead
> of ip6_flush_pending_frames.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

applied for net-2.6 and stable, thanks.

--yoshfuji
