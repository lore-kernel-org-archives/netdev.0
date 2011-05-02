From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Only allow recv on connected seqpacket
 sockets.
Date: Sun, 01 May 2011 23:16:49 -0700 (PDT)
Message-ID: <20110501.231649.71121140.davem@davemloft.net>
References: <m1sjt7sw32.fsf_-_@fess.ebiederm.org>
	<20110424.120519.226767465.davem@davemloft.net>
	<m1tydmo19o.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org, dan@aloni.org,
	stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753667Ab1EBGRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 02:17:22 -0400
In-Reply-To: <m1tydmo19o.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 25 Apr 2011 07:26:27 -0700

> When the other socket in an established connection calls unix_shutdown
> or unix_release_sock.  sk->sk_shutdown is changed, but sk_state is
> left at TCP_ESTABLISHED.  Therefore we do not need a special
> case in unix_seqpacket_recvmsg to handle the RCV_SHUTDOWN case
> because in any case where that applies we will be in TCP_ESTABLISHED
> and we will simply call unix_dgram_recvmsg.

Thanks for explaining Eric, patch applied.
