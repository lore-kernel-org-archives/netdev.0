From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6][NETNS]: Udp sockets per-net lookup.
Date: Thu, 31 Jan 2008 05:20:07 -0800 (PST)
Message-ID: <20080131.052007.165146562.davem@davemloft.net>
References: <47A1C216.9000303@openvz.org>
	<20080201.001138.95019632.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: yoshfuji@wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35276
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933705AbYAaNTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:19:47 -0500
In-Reply-To: <20080201.001138.95019632.yoshfuji@wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@wide.ad.jp>
Date: Fri, 01 Feb 2008 00:11:38 +1100 (EST)

> In article <47A1C216.9000303@openvz.org> (at Thu, 31 Jan 2008 15:41:58 +0300), Pavel Emelyanov <xemul@openvz.org> says:
> 
> > Add the net parameter to udp_get_port family of calls and 
> > udp_lookup one and use it to filter sockets.
> 
> I may miss something, but I'm afraid that I have to disagree.
> Port is identified only by family, address, protocol and port,
> and should not be split by name space.

It is like being on a totally different system.

Without sockets in namespaces, there is no point.

The networking devices are even per-namespace already,
so you can even say that each namespace is even
physically different.
