From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: [PATCH 6/6][NETNS]: Udp sockets per-net lookup.
Date: Fri, 01 Feb 2008 00:11:38 +1100 (EST)
Message-ID: <20080201.001138.95019632.yoshfuji@wide.ad.jp>
References: <47A1C216.9000303@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, devel@openvz.org,
	yoshfuji@wide.ad.jp
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39720 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765753AbYAaNLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:11:12 -0500
In-Reply-To: <47A1C216.9000303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47A1C216.9000303@openvz.org> (at Thu, 31 Jan 2008 15:41:58 +0300), Pavel Emelyanov <xemul@openvz.org> says:

> Add the net parameter to udp_get_port family of calls and 
> udp_lookup one and use it to filter sockets.

I may miss something, but I'm afraid that I have to disagree.
Port is identified only by family, address, protocol and port,
and should not be split by name space.

--yoshfuji
