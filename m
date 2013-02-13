From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add ability to set a timestamp offset
Date: Wed, 13 Feb 2013 13:22:54 -0500 (EST)
Message-ID: <20130213.132254.1534641136664469265.davem@davemloft.net>
References: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	edumazet@google.com, xemul@parallels.com
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964882Ab3BMSW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:22:57 -0500
In-Reply-To: <1360597819-23783-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>
Date: Mon, 11 Feb 2013 19:50:16 +0400

> If a TCP socket will get live-migrated from one box to another the
> timestamps (which are typically ON) will get screwed up -- the new
> kernel will generate TS values that has nothing to do with what they
> were on dump. The solution is to yet again fix the kernel and put a
> "timestamp offset" on a socket.
> 
> A socket offset is added in places where externally visible tcp
> timestamp option is parsed/initialized.
> 
> Connections in the SYN_RECV state are not supported, global
> tcp_time_stamp is used for them, because repair mode doesn't support
> this state. In a future it can be implemented by the similar way as for
> TIME_WAIT sockets.
> 
> For time-wait sockets offset is inhereted by a proper tcp_sock.
> 
> A per-socket offset can be set only for sockets in repair mode.

Series applied, thanks.
