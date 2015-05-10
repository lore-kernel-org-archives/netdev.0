From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Sat, 09 May 2015 22:15:54 -0400 (EDT)
Message-ID: <20150509.221554.38834063932093195.davem@davemloft.net>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbbEJCP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 22:15:56 -0400
In-Reply-To: <1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  7 May 2015 11:02:46 +0200

> This idea was informally discussed in Ottawa / netdev0.1. The goal is to
> ease the use/scalability of netns, from a userland point of view.
> Today, users need to open one netlink socket per family and per netns.
> Thus, when the number of netns inscreases (for example 5K or more), the
> number of sockets needed to manage them grows a lot.
> 
> The goal of this series is to be able to monitor netlink events, for a
> specified family, for a set of netns, with only one netlink socket. For
> this purpose, a netlink socket option is added: NETLINK_LISTEN_ALL_NSID.
> When this option is set on a netlink socket, this socket will receive
> netlink notifications from all netns that have a nsid assigned into the
> netns where the socket has been opened.
> The nsid is sent to userland via an anscillary data.

Series applied, thanks Nicolas.
